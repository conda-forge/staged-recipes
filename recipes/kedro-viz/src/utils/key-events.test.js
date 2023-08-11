import handleKeyEvent from './key-events.js';
import sinon from 'sinon';

describe('HandleKey Events', () => {
  it('handleKeyEvent is a function', () => {
    expect(typeof handleKeyEvent).toBe('function');
  });

  it('Invokes the correct actions when supplied a keycode', () => {
    const toCall = sinon.spy();
    const notToCall = sinon.spy();

    // 27 is keycode for escape
    handleKeyEvent(27, {
      escape: toCall,
      enter: notToCall,
    });

    expect(toCall.callCount).toBe(1);

    expect(notToCall.callCount).toBe(0);
  });

  it('Should return function if no actions are supplied', () => {
    expect(typeof handleKeyEvent(27)).toBe('function');
  });

  it('Should invoke correctly when single key is supplied', () => {
    const hke = handleKeyEvent(27);
    const spy = sinon.spy();

    hke('escape', spy);

    expect(spy.callCount).toBe(1);
  });

  it('Should throw if invalid values supplied', () => {
    /** Test null params */
    const test1 = () => {
      handleKeyEvent(null, null)();
    };

    /** Test empty params */
    const test2 = () => {
      handleKeyEvent()();
    };

    /** Test invalid params */
    const test3 = () => {
      handleKeyEvent(123, 'hello')();
    };

    expect(test1).toThrow();

    expect(test2).toThrow();

    expect(test3).toThrow();
  });
});
