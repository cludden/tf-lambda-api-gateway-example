const webpack = require('webpack');

module.exports = {
  target: 'node',
  entry: {
    'hello-world': './lib/hello-world',
  },
  output: {
    filename: '[name].js',
    libraryTarget: 'commonjs2',
    path: `${__dirname}/dist`,
  },
  module: {
    rules: [
      {
        test: /\.js$/,
        use: {
          loader: 'babel-loader',
        },
      },
    ],
  },
  plugins: [
    new webpack.optimize.UglifyJsPlugin({ sourceMap: true, mangle: false, compress: true }),
  ],
};
