<#
This script initializes a basic web application using MERN stack (MongoDB, Express, ReactJS, Node.js), Tailwind CSS, and Vite as a bundler.
It also installs Redux for state management and Axios for HTTP requests.

Exhecute with:
./setup-mern-app.ps1 -projectName "YourProjectName" -projectPath "C:\path\to\your\project"

Run client with:
cd YourProjectName\client
npm run dev

Run server with:
cd YourProjectName\server
npm run start
#>

param (
    [string]$projectName,
    [string]$projectPath
)

$currentDirectory = Get-Location

# 1. Create a directory with the project name
$fullProjectPath = Join-Path -Path $projectPath -ChildPath $projectName

if (-Not (Test-Path -Path $fullProjectPath)) {
    New-Item -ItemType Directory -Path $fullProjectPath -Force
}

# 2. Enter the project directory
Set-Location -Path $fullProjectPath

# 3. Create a new ReactJS project using Vite
npx create-vite@latest client --template react

$clientPath = Join-Path -Path $fullProjectPath -ChildPath "client"

# 4. Enter client directory
Set-Location -Path $clientPath

# 5 Remove src/App.css
Remove-Item -Path "src/App.css"

# 6. Replace the content of src/App.jsx
Set-Content -Path "src/App.jsx" -Value @'
import { useState } from "react";

function App() {
  return <div>Template with React, Vite, and Tailwind CSS</div>;
}

export default App;
'@

# 7. Clear src/index.css
Clear-Content -Path "src/index.css"

# 8. Remove src/assets/react.svg
Remove-Item -Path "src/assets/react.svg"

# 9. remove public/vite.svg
Remove-Item -Path "public/vite.svg"

# 10. Replace the content of public/index.html
Set-Content -Path "index.html" -Value @'
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <link rel="icon" type="image/svg+xml" href="" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Vite + React + Tailwind</title>
  </head>
  <body>
    <div id="root"></div>
    <script type="module" src="/src/main.jsx"></script>
  </body>
</html>
'@

# 11. Remove README.md
Remove-Item -Path "README.md"

# 12. Install client dependencies
npm install react-router-dom @reduxjs/toolkit react-redux redux-persist axios

# 13. Initialize Tailwind CSS
npm install -D tailwindcss postcss autoprefixer
npx tailwindcss init -p

# 14. Modify tailwind.config.js
Set-Content -Path "tailwind.config.js" -Value @'
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {},
  },
  plugins: [],
}
'@

# 15. Add Tailwind CSS to src/index.css
Add-Content -Path "src/index.css" -Value @'
@tailwind base;
@tailwind components;
@tailwind utilities;
'@

# 16. Go back to the original directory
Set-Location -Path "..\"

# 17. Create a new Node.js project
New-Item -ItemType Directory -Path "server"

Set-Location -Path "server"
# 18. Initialize a default Node.js project
npm init -y

# 19. Create the following directories
New-Item -ItemType Directory -Path "controllers"
New-Item -ItemType Directory -Path "routes"
New-Item -ItemType Directory -Path "models"

# 20. Install server dependencies
npm install body-parser cors express mongoose nodemon

# 21. Create index.js with the following content
Set-Content -Path "index.js" -Value @'
const express = require("express");
const bodyParser = require("body-parser");
const cors = require("cors");
const mongoose = require("mongoose");

const app = express();
app.use(cors());

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

mongoose
  .connect(process.env.MONGO_DB_URI || "mongodb://localhost:27017/ProjectName")
  .then(() => {
    console.log("Connesso a MongoDB");
  })
  .catch((error) => {
    console.error("Errore di connessione a MongoDB:", error);
  });

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => {
  console.log(`Server in esecuzione sulla porta ${PORT}`);
});
'@

# 22. Modify package.json to add a new script "start"
$json = Get-Content -Raw -Path "package.json" | ConvertFrom-Json
if (-Not $json.scripts) {
    $json | Add-Member -MemberType NoteProperty -Name scripts -Value @{}
}

# 23. Aggiungere il nuovo script "start"
$json.scripts | Add-Member -MemberType NoteProperty -Name start -Value "nodemon index.js"
$json | ConvertTo-Json -Depth 32 | Set-Content -Path "package.json"

# 24. Go back to the original directory
Set-Location -Path "..\"