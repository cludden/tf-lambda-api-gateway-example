require('webpack');

module.exports = {
  target: 'node',
  mode: 'production',
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
  optimization: {
    minimize: true,
  },
};
