module.exports = {
  watchOptions: {
    poll: true,
    ignored: /node_modules/
  },
  resolve: {
    extensions: ['.m.js', '.m.jsx', '...']
  },
  module: {
    rules: [
      {
        test: /\.(m?js|jsx)$/,
        exclude: /(node_modules|bower_components)/,
        use: {
          loader: 'babel-loader',
          options: {
            presets: ['@babel/preset-env']
          }
        }
      },
      {
        test: /\.css$/,
        use: ['style-loader', 'css-loader']
      },
      {
        test: /\.(jpg|jpeg|png|woff|woff2|eot|ttf|svg)$/,
        use: [{
            loader: 'url-loader',
            options: {
                limit: 50000
            }
    }],
}
    ]
  }
};