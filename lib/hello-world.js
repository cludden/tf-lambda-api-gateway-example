import { boomify, badRequest } from '@hapi/boom';

/**
 * Lambda request handler
 * @param  {Object}   e    - lambda event
 * @param  {Object}   ctx  - lambda context
 * @param  {Function} done - lambda callback
 * @return {Promise}
 */
export async function handler(e, ctx, done) {
  try {
    const body = parseJsonBody(e);
    const params = { name: body && body.name ? body.name : '' };
    const greeting = await hello(params);
    done(null, {
      statusCode: 200,
      headers: {
        'Content-Type': 'application/vnd.api+json',
      },
      body: JSON.stringify({ greeting }),
    });
  } catch (err) {
    boomify(err, { statusCode: 500, override: false });
    done(null, {
      statusCode: err.output.statusCode,
      headers: {
        'Content-Type': 'application/vnd.api+json',
      },
      body: JSON.stringify({
        errors: [{
          title: err.output.payload.error,
          detail: err.message,
          status: err.output.statusCode.toString(),
        }],
      }),
    });
  }
}

/**
 * Create a greeting for provided name
 * @param  {Object}  params      - parameters
 * @param  {String}  params.name - name
 * @return {Promise}
 */
export async function hello({ name }) {
  // wait for 10ms to simulate asynchronous function
  await new Promise((resolve) => setTimeout(resolve, 10));
  if (typeof name !== 'string') {
    throw badRequest('Name must be a string');
  }
  if (name === '') {
    return 'Hello World!';
  }
  return `Hello ${name}!`;
}

/**
 * Parse request body as JSON
 * @param  {Object} e - lambda event
 * @return {*}
 */
export function parseJsonBody(e) {
  try {
    return JSON.parse(e.body);
  } catch (err) {
    boomify(err, { statusCode: 400 });
    throw err;
  }
}
