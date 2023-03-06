# terraform example

## 概要

- terraform 使って deploy
  - apikey での認証もできた
  - ECR x lambda container
  - managed cache policy
- next SSR
  - BUILD_ID を固定することによって、lambda 側と static な assets のズレを解消する
  - cookie の動作確認

## やったこと

- intall

  - https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli

- tf apply
  - ecr の latest を見に行こうとしてコケた
  - 仕方ないからダミーを作って push
