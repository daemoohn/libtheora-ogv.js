workflow "Build libtheora" {
  on = "deployment"
  resolves = ["libtheoraBuildActions"]
}

action "libtheoraBuildActions" {
  uses = "./"
}
