# Use an official PHP image as a parent image
FROM php:7.4-cli

# Set the working directory in container
WORKDIR /usr/src/app

# Copy the local src directory contents into the container at /usr/src/app
COPY . .

# Use the PHP built-in server to serve it
CMD [ "php", "-S", "0.0.0.0:8080", "-t", "/usr/src/app" ]