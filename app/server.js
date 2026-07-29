const http = require("http");
const net = require("net");

const PORT = Number.parseInt(process.env.PORT || "80", 10);
const DB_HOST = process.env.DB_HOST || "not-configured";
const DB_PORT = Number.parseInt(process.env.DB_PORT || "3306", 10);

let instanceId = "unknown";
let availabilityZone = "unknown";

/**
 * Retrieve an IMDSv2 token.
 */
function getMetadataToken() {
  return new Promise((resolve, reject) => {
    const request = http.request(
      {
        host: "169.254.169.254",
        path: "/latest/api/token",
        method: "PUT",
        headers: {
          "X-aws-ec2-metadata-token-ttl-seconds": "21600"
        },
        timeout: 1500
      },
      (response) => {
        let body = "";

        response.on("data", (chunk) => {
          body += chunk;
        });

        response.on("end", () => {
          if (response.statusCode === 200) {
            resolve(body);
          } else {
            reject(
              new Error(`IMDS token request returned ${response.statusCode}`)
            );
          }
        });
      }
    );

    request.on("timeout", () => {
      request.destroy(new Error("IMDS token request timed out"));
    });

    request.on("error", reject);
    request.end();
  });
}

/**
 * Read one EC2 metadata field using IMDSv2.
 */
function getMetadata(path, token) {
  return new Promise((resolve, reject) => {
    const request = http.get(
      {
        host: "169.254.169.254",
        path: `/latest/meta-data/${path}`,
        headers: {
          "X-aws-ec2-metadata-token": token
        },
        timeout: 1500
      },
      (response) => {
        let body = "";

        response.on("data", (chunk) => {
          body += chunk;
        });

        response.on("end", () => {
          if (response.statusCode === 200) {
            resolve(body);
          } else {
            reject(
              new Error(`Metadata request returned ${response.statusCode}`)
            );
          }
        });
      }
    );

    request.on("timeout", () => {
      request.destroy(new Error("Metadata request timed out"));
    });

    request.on("error", reject);
  });
}

/**
 * Load the instance identity used in application responses.
 */
async function loadInstanceMetadata() {
  try {
    const token = await getMetadataToken();

    [instanceId, availabilityZone] = await Promise.all([
      getMetadata("instance-id", token),
      getMetadata("placement/availability-zone", token)
    ]);

    console.log(
      `Loaded metadata: instance=${instanceId}, az=${availabilityZone}`
    );
  } catch (error) {
    console.error(`Unable to load EC2 metadata: ${error.message}`);
  }
}

/**
 * Test whether the database placeholder accepts a TCP connection.
 */
function checkDatabase() {
  return new Promise((resolve) => {
    if (DB_HOST === "not-configured") {
      resolve({
        status: "not_configured",
        host: DB_HOST,
        port: DB_PORT,
        response: null
      });
      return;
    }

    const socket = new net.Socket();
    let response = "";
    let finished = false;

    function complete(result) {
      if (finished) {
        return;
      }

      finished = true;
      socket.destroy();
      resolve(result);
    }

    socket.setTimeout(2000);

    socket.connect(DB_PORT, DB_HOST, () => {
      console.log(`Connected to database placeholder ${DB_HOST}:${DB_PORT}`);
    });

    socket.on("data", (data) => {
      response += data.toString();

      try {
        const parsed = JSON.parse(response.trim());

        complete({
          status: "connected",
          host: DB_HOST,
          port: DB_PORT,
          response: parsed
        });
      } catch {
        // Wait for additional data if the JSON response is incomplete.
      }
    });

    socket.on("end", () => {
      complete({
        status: "connected",
        host: DB_HOST,
        port: DB_PORT,
        response: response.trim() || null
      });
    });

    socket.on("timeout", () => {
      complete({
        status: "timeout",
        host: DB_HOST,
        port: DB_PORT,
        response: null
      });
    });

    socket.on("error", (error) => {
      complete({
        status: "unavailable",
        host: DB_HOST,
        port: DB_PORT,
        error: error.message,
        response: null
      });
    });
  });
}

function sendJson(response, statusCode, data) {
  response.writeHead(statusCode, {
    "Content-Type": "application/json",
    "Cache-Control": "no-store"
  });

  response.end(JSON.stringify(data, null, 2));
}

function sendHtml(response, statusCode, html) {
  response.writeHead(statusCode, {
    "Content-Type": "text/html; charset=utf-8",
    "Cache-Control": "no-store"
  });

  response.end(html);
}

const server = http.createServer(async (request, response) => {
  const requestUrl = new URL(
    request.url,
    `http://${request.headers.host || "localhost"}`
  );

  /*
   * Keep the ALB health check independent of the database.
   * The App Tier should remain healthy if the database temporarily fails.
   */
  if (requestUrl.pathname === "/health") {
    sendJson(response, 200, {
      status: "healthy",
      tier: "application",
      instanceId,
      availabilityZone,
      timestamp: new Date().toISOString()
    });
    return;
  }

  if (requestUrl.pathname === "/api/stats") {
    const database = await checkDatabase();

    sendJson(response, 200, {
      application: {
        status: "healthy",
        instanceId,
        availabilityZone
      },
      database,
      timestamp: new Date().toISOString()
    });
    return;
  }

  if (requestUrl.pathname === "/") {
    const database = await checkDatabase();

    const connected = database.status === "connected";
    const databaseLabel = connected ? "Connected" : database.status;

    sendHtml(
      response,
      200,
      `<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>AWS Three-Tier Architecture</title>
  <style>
    body {
      background: #f4f6f8;
      color: #18212f;
      font-family: Arial, sans-serif;
      margin: 0;
      padding: 40px 20px;
    }

    main {
      background: white;
      border-radius: 12px;
      box-shadow: 0 8px 24px rgba(0, 0, 0, 0.08);
      margin: auto;
      max-width: 760px;
      padding: 32px;
    }

    h1 {
      margin-top: 0;
    }

    .tier {
      border-left: 5px solid #59636e;
      margin: 20px 0;
      padding: 12px 18px;
    }

    .connected {
      font-weight: bold;
    }

    code {
      background: #eef1f4;
      border-radius: 4px;
      padding: 3px 6px;
    }
  </style>
</head>
<body>
  <main>
    <h1>AWS Three-Tier Cloud Architecture</h1>

    <section class="tier">
      <h2>Tier 1: Presentation</h2>
      <p>Traffic received through the internet-facing Application Load Balancer.</p>
    </section>

    <section class="tier">
      <h2>Tier 2: Application</h2>
      <p><strong>Instance ID:</strong> <code>${instanceId}</code></p>
      <p><strong>Availability Zone:</strong> <code>${availabilityZone}</code></p>
    </section>

    <section class="tier">
      <h2>Tier 3: Data</h2>
      <p>
        <strong>Database status:</strong>
        <span class="${connected ? "connected" : ""}">${databaseLabel}</span>
      </p>
      <p><strong>Database endpoint:</strong> <code>${DB_HOST}:${DB_PORT}</code></p>
    </section>

    <p>
      API endpoint: <a href="/api/stats">/api/stats</a><br>
      Health endpoint: <a href="/health">/health</a>
    </p>
  </main>
</body>
</html>`
    );
    return;
  }

  sendJson(response, 404, {
    error: "Not Found",
    path: requestUrl.pathname
  });
});

loadInstanceMetadata().finally(() => {
  server.listen(PORT, "0.0.0.0", () => {
    console.log(
      `Three-tier application listening on port ${PORT}; DB=${DB_HOST}:${DB_PORT}`
    );
  });
});
