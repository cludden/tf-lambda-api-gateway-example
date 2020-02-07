import { fromCallback } from 'bluebird';
import { expect } from 'chai';
import { describe, it } from 'mocha';

import { handler } from '../../lib/hello-world';
import { apiGatewayRequest } from '../utils/events';

describe('hello-world', () => {
  it('should fail (400) if the request body is not valid JSON', async function () {
    const e = apiGatewayRequest({ body: 'hello++' });
    const res = await fromCallback((done) => handler(e, {}, done));
    expect(res).to.have.property('statusCode', 400);
    expect(res).to.have.nested.property('headers.Content-Type', 'application/vnd.api+json');
    expect(res).to.have.property('body').that.is.a('string');
    const payload = JSON.parse(res.body);
    expect(payload).to.have.property('errors').that.is.an('array').with.lengthOf(1);
    expect(payload).to.have.nested.property('errors.0.title', 'Bad Request');
    expect(payload).to.have.nested.property('errors.0.status', '400');
  });

  it('should fail (400) if a non-string is provided for name', async function () {
    const e = apiGatewayRequest({ body: { name: 1 } });
    const res = await fromCallback((done) => handler(e, {}, done));
    expect(res).to.have.property('statusCode', 400);
    expect(res).to.have.nested.property('headers.Content-Type', 'application/vnd.api+json');
    expect(res).to.have.property('body').that.is.a('string');
    const payload = JSON.parse(res.body);
    expect(payload).to.have.property('errors').that.is.an('array').with.lengthOf(1);
    expect(payload).to.have.nested.property('errors.0.title', 'Bad Request');
    expect(payload).to.have.nested.property('errors.0.detail', 'Name must be a string');
    expect(payload).to.have.nested.property('errors.0.status', '400');
  });

  it('should use World as the name if name is missing or empty (200)', async function () {
    const e = apiGatewayRequest({ body: { foo: 'bar' } });
    const res = await fromCallback((done) => handler(e, {}, done));
    expect(res).to.have.property('statusCode', 200);
    expect(res).to.have.nested.property('headers.Content-Type', 'application/vnd.api+json');
    expect(res).to.have.property('body').that.is.a('string');
    const payload = JSON.parse(res.body);
    expect(payload).to.have.property('greeting', 'Hello World!');
  });

  it('should use the provided name (200)', async function () {
    const e = apiGatewayRequest({ body: { name: 'Bob' } });
    const res = await fromCallback((done) => handler(e, {}, done));
    expect(res).to.have.property('statusCode', 200);
    expect(res).to.have.nested.property('headers.Content-Type', 'application/vnd.api+json');
    expect(res).to.have.property('body').that.is.a('string');
    const payload = JSON.parse(res.body);
    expect(payload).to.have.property('greeting', 'Hello Bob!');
  });
});
