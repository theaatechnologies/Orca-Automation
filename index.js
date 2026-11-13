// Simple Node.js application example

class Calculator {
  add(a, b) {
    return a + b;
  }

  subtract(a, b) {
    return a - b;
  }

  multiply(a, b) {
    return a * b;
  }

  divide(a, b) {
    if (b === 0) {
      throw new Error('Division by zero');
    }
    return a / b;
  }
}

class App {
  constructor(name, version) {
    this.name = name;
    this.version = version;
    this.calculator = new Calculator();
  }

  start() {
    console.log(`Starting ${this.name} v${this.version}`);
    return true;
  }

  getInfo() {
    return {
      name: this.name,
      version: this.version
    };
  }
}

module.exports = { App, Calculator };
