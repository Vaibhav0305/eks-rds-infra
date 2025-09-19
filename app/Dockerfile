# Use lightweight Node.js image
FROM node:18-alpine

# Set working directory inside container
WORKDIR /usr/src/app

# Copy package files first (better for caching layers)
COPY package*.json ./

# Install only production dependencies
RUN npm install --only=production

# Copy rest of the app source code
COPY . .

# Expose port that app runs on
EXPOSE 3000

# Command to run the app
CMD ["node", "index.js"]
