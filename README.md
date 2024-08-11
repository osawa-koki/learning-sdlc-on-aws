# learning-sdlc-on-aws

🍱🍱🍱 AWSでの基本的なSDLC技術を学ぶ！  

![成果物](./fruit.gif)  

## このリポジトリについて

以下の技術を学ぶためのリポジトリ！  

- ~~ CodeCommit ~~ (-> GitHub)
- CodeBuild
- CodeDeploy
- CodePipeline
※ ソースコード管理はGitHubの方が好きなので、、、  

FastAPIのサンプルコードをEC2のAmazon Linux2にCI/CD(CodeFamily)を用いて自動でデプロイしてみます！！！  
IaCはCloudFormationを使用しています！  

あくまでも学習用のリポジトリですので、セキュリティなどは考慮していません。  

## 開発環境の構築方法

最初にAWS CLIをインストールします。  
<https://docs.aws.amazon.com/ja_jp/cli/latest/userguide/install-cliv2.html>  

以下のコマンドを実行して、AWS CLIのバージョンが表示されればOKです。  

```shell
aws --version
```

認証情報を設定します。  

```shell
aws configure
```

以下のように聞かれるので、適宜入力してください。

```shell
AWS Access Key ID [None]: アクセスキーID
AWS Secret Access Key [None]: シークレットアクセスキー
Default region name [None]: リージョン名
Default output format [None]: json
```

## 実行方法

`./parameters.txt.example`をコピーして、`./parameters.txt`を作成します。  
`./parameters.txt`には、パラメタを記述します。  

`SSHPublicKey`は、EC2にログインするための公開鍵です。  
以下のコマンドで作成できます。  

```shell
ssh-keygen -t rsa -b 4096
```

以下のコマンドを実行すると、CloudFormationがデプロイされます。  

```shell
PARAMS=$(cat ./parameters.txt | tr '\n' ' ')
eval aws cloudformation deploy \
    --template-file ./template.yml \
    --stack-name <STACK_NAME> \
    --parameter-overrides $PARAMS \
    --capabilities CAPABILITY_NAMED_IAM
```

以下のコマンドで、EC2にログインできます。  

```shell
ssh -i ~/.ssh/id_rsa -l <UserName> <EC2のパブリックIP>
```

UserNameはデフォルト(Amazon Linux系)では、`ec2-user`です。  
<https://docs.aws.amazon.com/ja_jp/AWSEC2/latest/UserGuide/managing-users.html>を参考に、適宜読み替えてください。  

IPアドレスは、Outputで指定した`EC2PublicIP`を指定します。  
Outputで指定した値の取得方法は、後述します。  

---

`Output`で指定した値を取得するには、以下のコマンドを実行します。  

```shell
aws cloudformation describe-stacks --stack-name <STACK_NAME> --query "Stacks[].Outputs[?OutputKey=='EC2PublicIP'].OutputValue" --output text --no-cli-pager
```

削除するには、以下のコマンドを実行します。  

```shell
aws cloudformation delete-stack --stack-name <STACK_NAME>
```

## トラブルシュート

- CloudFormationのデプロイが失敗する場合
  - CloudFormationのコンソールで、エラーメッセージを確認する。
  - ロールの権限が足りない場合、IAMのコンソールで権限を追加する。
  - パラメタの値が間違っている場合、`./parameters.txt`を確認する。
  - テンプレートの記述が間違っている場合、`./template.yml`を確認する。
- EC2にログインできない場合
  - `SSHPublicKey`が間違っている場合、`./parameters.txt`を確認する。
  - ユーザ名が正しいか、EC2のAMIに合わせているか確認する。
  - セキュリティグループの設定が間違っている場合、EC2のコンソールで確認する。
  - EC2のインスタンスが起動していない場合、EC2のコンソールで確認する。
- CodeDeployエージェントが動作しているか確認する
  - EC2のコンソールで、`service codedeploy-agent status`を実行して、`codedeploy-agent`が動作しているか確認する。
- CodeDeployのログを確認する
  - EC2のコンソールで、`tail /var/log/aws/codedeploy-agent/codedeploy-agent.log`を実行して、ログを確認する。
  - `Missing credentials - please check if this instance was started with an IAM instance profile`というエラーが出ている場合、IAMロールの設定を確認する。
    - EC2作成後にロールを付与した場合は、正しく認証情報が取得できていないかもしれません、、、
    - `service codedeploy-agent restart`を実行して、再起動すると解決するかもしれません、、、

## 所感

- LinuxにインストールされるPythonのバージョンが古かったりパッケージが古かったりするので、やはりDocker&ECRでデプロイ先はECSの方が良いかもしれません、、、
  - 次回はECSでデプロイしてみたいです！！！
- GitHub Actionsの方がログと進捗が見やすい気がしました、、、
  - CodePipelineに慣れていないだけかもしれませんが、、、
- シークレットやパラメタの管理はGitHub Actionsに比べて、CodeFamilyの方が一元的に管理できる気がしました！！！
  - GitHub Actionsはステップをまたいでのシークレットの共有が煩雑になりがち、、、
