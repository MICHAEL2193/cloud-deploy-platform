const express = require("express");

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

let tasks = [
  { id: 1, title: "Preparar proyecto cloud", status: "pending" },
  { id: 2, title: "Dockerizar la aplicación", status: "pending" }
];

app.get("/", (req, res) => {
  res.json({
    message: "Cloud Deploy Platform API",
    version: "1.0.0",
    endpoints: ["/health", "/ready", "/tasks"]
  });
});

app.get("/health", (req, res) => {
  res.status(200).json({
    status: "ok",
    service: "app",
    uptime: process.uptime()
  });
});

app.get("/ready", (req, res) => {
  res.status(200).json({
    status: "ready",
    checks: {
      app: "ok"
    }
  });
});

app.get("/tasks", (req, res) => {
  res.status(200).json(tasks);
});

app.post("/tasks", (req, res) => {
  const { title, status } = req.body;

  if (!title) {
    return res.status(400).json({
      error: "El campo 'title' es obligatorio"
    });
  }

  const newTask = {
    id: tasks.length + 1,
    title,
    status: status || "pending"
  };

  tasks.push(newTask);

  return res.status(201).json(newTask);
});

app.listen(PORT, "0.0.0.0", () => {
  console.log(`Servidor escuchando en http://0.0.0.0:${PORT}`);
});
