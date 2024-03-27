# git命令总结

## 创建git

### 创建仓库命令

下表列出了 git 创建仓库的命令：

| 命令        | 说明                                   |
| :---------- | :------------------------------------- |
| `git init`  | 初始化仓库                             |
| `git clone` | 拷贝一份远程仓库，也就是下载一个项目。 |

### 提交与修改

Git 的工作就是创建和保存你的项目的快照及与之后的快照进行对比。下表列出了有关创建与提交你的项目的快照的命令：

| 命令                                | 说明                                     |
| :---------------------------------- | :--------------------------------------- |
| `git add`                           | 添加文件到暂存区                         |
| `git status`                        | 查看仓库当前的状态，显示有变更的文件。   |
| `git diff`                          | 比较文件的不同，即暂存区和工作区的差异。 |
| `git commit`                        | 提交暂存区到本地仓库。                   |
| `git reset`                         | 回退版本。                               |
| `git rm`                            | 将文件从暂存区和工作区中删除。           |
| `git mv`                            | 移动或重命名工作区文件。                 |
| `git checkout`                      | 分支切换。                               |
| `git switch （Git 2.23 版本引入）`  | 更清晰地切换分支。                       |
| `git restore （Git 2.23 版本引入）` | 恢复或撤销文件的更改。                   |

### 提交日志

| 命令               | 说明                                 |
| :----------------- | :----------------------------------- |
| `git log`          | 查看历史提交记录                     |
| `git blame <file>` | 以列表形式查看指定文件的历史修改记录 |

### 远程操作

| 命令         | 说明               |
| :----------- | :----------------- |
| `git remote` | 远程仓库操作       |
| `git fetch`  | 从远程获取代码库   |
| `git pull`   | 下载远程代码并合并 |
| `git push`   | 上传远程代码并合并 |

## git因commit100MB以上大文件导致push失败解决方法

### 1 看哪个文件占的大

注意这一句：`remote: error: File resultDataset/resultDataset/gplus_combined.csv is 1279.62 MB; this exceeds Git`

### 2 重写commit，删除大文件

```bash
git filter-branch --force --index-filter 'git rm -rf --cached --ignore-unmatch resultDataset/resultDataset/gplus_combined.csv' --prune-empty --tag-name-filter cat -- --all
```

需要注意的是，此处可能会报错，出现这个错误

```bash
Cannot rewrite branches: You have unstaged changes
```

解决方案：执行`git stash`即可解决。

### 3 推送修改后的repo

以强制覆盖的方式推送你的repo, 命令如下:

```bash
git push origin master --force
```

### 4 清理和回收空间

虽然上面我们已经删除了文件, 但是我们的repo里面仍然保留了这些objects, 等待垃圾回收(GC), 所以我们要用命令彻底清除它, 并收回空间，命令如下:

```bash
rm -rf .git/refs/original/
git reflog expire --expire=now --all
git gc --prune=now
```

### 如果上述方法不管用

可以按照以下方法：

### 1、移除错误缓存

首先应该移除所有错误的 cache，对于文件：

```bash
git rm --cached path_of_a_giant_file
```

对于文件夹：

```bash
git rm --cached -r path_of_a_giant_dir
```

例如对于我的例子就是这样的：

```bash
git rm --cached resultDataset/resultDataset/gplus_combined.csv
```

### 2、重新提交

编辑最后提交信息：

```bash
git commit --amend
```

修改 log 信息后保存返回。
重新提交

```bash
git push
```

## github：master提交项目到远程仓库出现“There isn’t anything to compare.”

### 解决办法

```shell
# 切换分支至master
git checkout master
# 强制重命名master分支为main分支
git branch main master -f
# 切换分支至main
git checkout main
# 强制推送本地main分支至远程库，并覆盖远程main分支内容
git push origin main -f
```

## Github——git本地仓库建立与远程连接（windows）

### config设置（增删改查）

**设置username 和 email**

```javascript
$ git config --global user.name  "name"//自定义用户名
$ git config --global user.email "youxiang@qq.com"//用户邮箱
```

**修改**

```
git config --global configname configvalue
```

**查询**

```
git config --global configname
```

**查询全部**

```
git config --list
```

### github与git连接——本地Git仓库

#### 建本地的版本库

等同于新建一个空文件夹，进入，右键-Git Bash-输入“git init”初始化成一个Git可管理的仓库。这时文件夹里多了个.git文件夹，它是Git用来跟踪和管理版本库的。如果你看不到，需要设置一下让隐藏文件可见。 

#### 源代码放入本地仓库

把项目/源代码粘贴到这个本地Git仓库里面。

**git status：查看当前的状态**

- 红字表示未add到Git仓库上的文件
- 绿字表示已add到Git仓库上的文件

然后通过**git add**把项目/源代码添加到仓库
（“git add .” ：把该目录下的所有文件添加到仓库，注意点“.”）

可以看到，查询状态后文件已经变为绿色，说明add成功

#### 提交仓库

用**git commit**把项目提交到仓库。
-m 后面引号里面是本次提交的注释内容，可以不写，但最好写上，不然会报错

```javascript
git commit -m "first commit"
```

### github与git的连接——远程连接

本地Git仓库和GitHub仓库之间的传输是**通过SSH加密传输的**，所以需要配置ssh key。

#### 创建SSH Key

在用户主目录下，查询是否存在“.ssh”文件。

- 如果有，再看文件下有没有id_rsa和id_rsa.pub这两个文件，如果也有，可直接到下一步。
- 如果没有，在开始附录里找到Git Bash，输入命令，创建SSH Key.

```javascript
$ ssh-keygen -t rsa -C "youxiang@qq.com"
```

SSH Key的秘钥对：**id_rsa是私钥，不能泄露；id_rsa.pub是公钥，可以公开。**

#### github填写SSH Key

打开“Account settings”–“SSH Keys”页面，点击“Add SSH Key”，title随意，key填写id_rsa.pub的全部内容

#### 验证

①验证是否成功，在git bash里输入下面的命令

```javascript
$ ssh -T git@github.com
```

②初次设置需要输入yes，出现第二个红框内容表示成功。

#### 关联远程仓库

根据创建好的Git仓库页面的提示（找自己仓库的提示代码），可以在本地Elegent仓库的命令行输入：

```javascript
git remote add origin https://github.com/xu-xiaoya/Elegent.git
```

#### 本地内容上传推送

联好之后我们就可以把本地库的所有内容推送到远程仓库（也就是Github）上了，通过在Bash输入：

- 由于新建的远程仓库是空的，所以要加上-u这个参数
  `git push -u origin master`
- 之后仓库不是空的，就不用加上-u
  `git push origin master`

## 常见错误（不断更新中）

①问题一：新建远程仓库的时候勾选Initialize this repository with a README，推送时可能会报failed to push some refs to https://github.com/xu-xiaoya/Elegent.git的错。

**解决方案**：这是由于你新创建的那个仓库里面的README文件不在本地仓库目录中，这时可以同步内容。

```javascript
$ git pull --rebase origin master
```

之后再进行git push origin master就能成功了。