#!/usr/bin/env sh
bash
yarn global add create-react-app
yarn global add @api-platform/client-generator
create-react-app .
chown node:node -R .
yarn add redux react-redux redux-thunk redux-form react-router-dom react-router-redux prop-types
yarn install
yarn start
