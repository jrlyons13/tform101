# Define a docker provider
provider "docker" {
  host = "unix:///var/run/docker.sock"
}

# Create a nginx container
resource "docker_container" "nginx" {
  image = docker_image.nginx.latest
  name  = "nginx"
  ports {
    internal = 80
    external = 8080
  }
}

# Create a nginx image
resource "docker_image" "nginx" {
  name = "nginx:latest"
}

# Run a command on the container to append text to the index.html file
resource "null_resource" "append_text" {
  # Trigger this resource when the container is created or changed
  triggers = {
    container_id = docker_container.nginx.id
  }

  # Use the remote-exec provisioner to run a command
  provisioner "remote-exec" {
    inline = [
      "echo 'Hello World this is my new Server' >> /usr/share/nginx/html/index.html" # The command to append text
    ]
    connection {
      type  = "docker"
      container = self.triggers.container_id
    }
  }
}
