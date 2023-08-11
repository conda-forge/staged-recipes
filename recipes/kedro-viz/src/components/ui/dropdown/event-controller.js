/**
 * Event Controller for managing listeners for the dropdown component.
 * Handles adding and removing listeners attached to body of the document.
 */
class EventController {
  /**
   * Manages the attachment of the event listener when body is clicked.
   * @param {Object} eventHandler - event handler which will be added
   */
  static addBodyListener(eventHandler) {
    if (typeof window.__bodyEventHandlers === 'undefined') {
      window.__bodyEventHandlers = [];
    }

    // add event handler to the array attached to the window so that it can be retrieved outside of component
    window.__bodyEventHandlers.push(eventHandler);
    // add the event handler to the body
    document.body.addEventListener('click', eventHandler);

    // indicate that event listeners are attached
    window.__bodyListenerAttached = true;
  }

  /**
   * Manages the removal of the event listeners when body is clicked - all event listeners added
   * by dropdown components are removed.
   * This method is static because it doesn't utilize 'this'.
   */
  static removeBodyListeners() {
    if (window.__bodyListenerAttached) {
      // remove all event listeners attached to body
      window.__bodyEventHandlers.forEach((handler) => {
        document.body.removeEventListener('click', handler);
      });

      // indicate that no listeners are attached and reset the array
      window.__bodyEventHandlers = [];
      window.__bodyListenerAttached = false;
    }
  }
}

export default EventController;
