const { Calculator, App } = require('../../index');

describe('Calculator', () => {
  let calculator;

  beforeEach(() => {
    calculator = new Calculator();
  });

  describe('add', () => {
    test('should add two positive numbers', () => {
      expect(calculator.add(2, 3)).toBe(5);
    });

    test('should add negative numbers', () => {
      expect(calculator.add(-2, -3)).toBe(-5);
    });

    test('should add zero', () => {
      expect(calculator.add(5, 0)).toBe(5);
    });
  });

  describe('subtract', () => {
    test('should subtract two numbers', () => {
      expect(calculator.subtract(5, 3)).toBe(2);
    });

    test('should handle negative results', () => {
      expect(calculator.subtract(3, 5)).toBe(-2);
    });
  });

  describe('multiply', () => {
    test('should multiply two numbers', () => {
      expect(calculator.multiply(3, 4)).toBe(12);
    });

    test('should handle multiplication by zero', () => {
      expect(calculator.multiply(5, 0)).toBe(0);
    });
  });

  describe('divide', () => {
    test('should divide two numbers', () => {
      expect(calculator.divide(10, 2)).toBe(5);
    });

    test('should throw error on division by zero', () => {
      expect(() => calculator.divide(10, 0)).toThrow('Division by zero');
    });
  });
});

describe('App', () => {
  let app;

  beforeEach(() => {
    app = new App('TestApp', '1.0.0');
  });

  test('should create app with name and version', () => {
    expect(app.name).toBe('TestApp');
    expect(app.version).toBe('1.0.0');
  });

  test('should start successfully', () => {
    expect(app.start()).toBe(true);
  });

  test('should return app info', () => {
    const info = app.getInfo();
    expect(info).toEqual({
      name: 'TestApp',
      version: '1.0.0'
    });
  });

  test('should have calculator instance', () => {
    expect(app.calculator).toBeInstanceOf(Calculator);
  });
});
