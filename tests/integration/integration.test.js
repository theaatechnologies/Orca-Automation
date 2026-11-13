const { App, Calculator } = require('../../index');

describe('Integration Tests', () => {
  describe('App with Calculator Integration', () => {
    let app;

    beforeEach(() => {
      app = new App('IntegrationTest', '1.0.0');
    });

    test('should perform calculations through app', () => {
      const result1 = app.calculator.add(5, 3);
      const result2 = app.calculator.multiply(result1, 2);
      
      expect(result1).toBe(8);
      expect(result2).toBe(16);
    });

    test('should handle complex calculation chains', () => {
      const calc = app.calculator;
      
      const result = calc.add(
        calc.multiply(2, 3),
        calc.divide(10, 2)
      );
      
      expect(result).toBe(11);
    });

    test('should maintain state across operations', () => {
      expect(app.start()).toBe(true);
      
      const info = app.getInfo();
      expect(info.name).toBe('IntegrationTest');
      
      const calcResult = app.calculator.add(1, 1);
      expect(calcResult).toBe(2);
    });
  });

  describe('Error Handling Integration', () => {
    test('should handle errors gracefully', () => {
      const app = new App('ErrorTest', '1.0.0');
      
      expect(() => {
        app.calculator.divide(10, 0);
      }).toThrow('Division by zero');
    });
  });
});
