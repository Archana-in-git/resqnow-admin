#!/usr/bin/env node

const { execSync } = require("child_process");

console.log("Deploying Cloud Functions...");

try {
  const result = execSync("firebase deploy --only functions --force", {
    cwd: "C:\\Users\\Archanaa\\Desktop\\resqnow_admin",
    stdio: "inherit",
  });
  console.log("✅ Deployment completed successfully");
} catch (error) {
  console.error("❌ Deployment failed:", error.message);
  process.exit(1);
}
