/**
 * Backend API request HTTP client module  for making backend API requests
 *   - Provides the Axios HTTP client API  for drop-in replacement of Axios
 *   - Redirects to login upon non-authenticated request responses
 *       (e.g., 401 Unauthorized error status code)
 * @module
 * @example
 *   import request from './request';
 *   // Use request like axios
 * @see {@link https://axios-http.com/docs/intro Axios documentation}
 * @see {@link https://github.com/axios/axios    Axios GitHub repository}
 */

'use strict';

import axios from 'axios';

let request = axios.create();  // instance that is independent of axios imports

// Redirect to login upon non-authenticated request responses
request.interceptors.response.use( response => response, error => {

  if (error.response.status === 401) {
    window.location = '/login';
    // TODO Unhardcode (e.g., via future router path)
  }

  return Promise.reject(error);
});

/**
 * Send an HTTP request
 * @see axios
 * @see {@link https://axios-http.com/docs/intro Axios documentation}
 * @see {@link https://github.com/axios/axios    Axios GitHub repository}
 */
export default request;