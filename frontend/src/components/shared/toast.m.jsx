/**
 * UI user toast notification module  for notifying UI users via toasts
 * @module
 * @example
 *   // Add <div id="toasts"></div> to HTML
 *   import toast from './toast';
 *   toast.success('Added');
 */

'use strict';

import React from 'react';
import ReactDOM from 'react-dom';

/** Toaster for adding toasts */
class Toaster extends React.Component {

  constructor(props) {
    super(props);
    this.state = {};
  }

  #keyCount = 0;

  /** Add toast */
  add(message, level = toast.INFO) {

    this.setState(state => {

      if (! state.toasts) {
        state.toasts = new Map();
      }

      // Based on preexisting Bootstrap Alerts
      let key                  = ++this.#keyCount,
          classSuffixesByLevel = {
            error: 'danger'  // Bootstrap 3-4
          },
          className            = `alert-${classSuffixesByLevel[level] || level}`;
                                // Default to alert-{level}
      state.toasts.set(key,
        <div key={key} className={`alert fade in ${className}`}>
          <button type="button" className="close" onClick={() => this.#remove(key)}>&times;</button>
          {message.toString()}{/* in case exception etc. */}
        </div>
      );

      return {toasts: state.toasts};
    })
  }

  /** Remove toast */
  #remove(key) {
    this.setState(state => {
      state.toasts.delete(key);
      return {toasts: state.toasts};
    })
  }

  /** @see React.Component#render */
  render() {
    // Using preexisting layout
    return this.state.toasts && this.state.toasts.size ?
      <div className="container-fluid message-margin">
        {Array.from(this.state.toasts.values())}
      </div>
      :
      <></>
    ;
  }
}


let toaster;

/** Add toast */
export default function toast(message, level = toast.INFO) {

  toaster ? toaster.add(message, level) :
    ReactDOM.render(
      <Toaster ref={(component) => {
        toaster = component;
        toaster.add(message, level);
      }} />,
      document.getElementById('toasts')
    );
}

// Notification levels  built in
//   Note:  Using function to further condense code below prevents IDE code completion

/** Info notification level */
toast.INFO    = 'info';
/** Success notification level */
toast.SUCCESS = 'success';
/** Warning notification level */
toast.WARNING = 'warning';
/** Error notification level */
toast.ERROR   = 'error';

/** Add info toast */
toast.info    = message => { toast(message, toast.INFO); }
/** Add success toast */
toast.success = message => { toast(message, toast.SUCCESS); }
/** Add warning toast */
toast.warning = message => { toast(message, toast.WARNING); }
/** Add error toast */
toast.error   = message => { toast(message, toast.ERROR); }

Object.freeze(toast);  // Make read-only