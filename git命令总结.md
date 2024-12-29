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

### git本地仓库与远程仓库连接

```
git remote add origin 远程仓库url（.git）
git remote -v 查看远程仓库
```

### 首次git时需要表明身份

```
git config --global user.email "ruanqingxuan11@gmail.com"
git config --global user.name "qnwang"
```

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
git push origin main --force
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
$ git pull --rebase origin main
```

之后再进行git push origin main就能成功了。

②问题二：完美解决 git 报错 “fatal: unable to access ‘https://github.com/.../.git‘: Recv failure Connection was rese

**解决方案**：取消代理设置。这是最常见的解决方法之一，通过在终端执行以下命令，可以取消 Git 的代理设置：

```
git config --global --unset http.proxy  
git config --global --unset https.proxy
```

③问题三：git本地修改，远程库也修改了如何提交代码

**解决方案**：先隐藏掉本地的修改，然后执行git pull从代码块拉取最新代码，具体步骤如下：

```
git status 查看本地的修改
git stash 隐藏掉本地修改
git pull 从代码库拉取更新
git stash pop stash@{版本号}
git add 、git commit 、git push
```

④问题四：Git git push显示一切都是最新的，但实际上并不是

**解决方案**：确保我们使用`git add`命令将所有要提交的文件添加到暂存区，然后使用`git commit`命令进行提交。然后再使用git push将更改推送到远程存储库。

⑤问题五：Pulling is not possible because you have unmerged files.

```bash
git mergetool
git pull --rebase origin main 
```

上述命令基本上会针对每个冲突文件打开本地文件、混合文件、远程文件（总共 3 个文件）。本地文件和远程文件仅供您参考，使用它们您可以选择在混合文件中包含（或不包含）哪些内容。然后只需保存并退出文件即可。

⑥问题六：interactive rebase in progress; onto 7061393

```bash
git rebase --continue
```



# 如何使用 SSH 链接远程 Git 仓库

## 🗒️ Answer

使用 SSH 连接远程 Git 仓库可以避免每次推送代码时输入用户名和密码，且更安全。以下是设置和使用 SSH 链接 Git 仓库的步骤：

### 1. **生成 SSH 密钥**
首先，你需要在本地机器上生成 SSH 密钥对（如果尚未生成）：

```bash
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

这会生成一个公钥和私钥（通常存储在 `~/.ssh/` 目录下，默认文件名为 `id_rsa` 和 `id_rsa.pub`）。

### 2. **添加 SSH 公钥到 GitHub**
将生成的公钥添加到 GitHub 上：

1. 复制公钥的内容：
   ```bash
   cat ~/.ssh/id_rsa.pub
   ```
   然后复制输出的内容。

2. 登录到 GitHub，进入 **Settings** > **SSH and GPG keys**，点击 **New SSH key**，粘贴刚才复制的公钥内容，并保存。

### 3. **测试 SSH 连接**
在本地测试 SSH 连接是否成功：

```bash
ssh -T git@github.com
```

如果成功，GitHub 会返回类似以下信息：
```bash
Hi username! You've successfully authenticated, but GitHub does not provide shell access.
```

### 4. **克隆仓库或配置现有仓库的远程地址**
使用 SSH URL 来克隆远程仓库：

```bash
git clone git@github.com:username/repository.git
```

如果已经克隆了仓库并想要修改远程 URL 以使用 SSH，可以执行以下命令：

```bash
git remote set-url origin git@github.com:username/repository.git
```

### 5. **推送代码**
现在，你可以通过 SSH 协议推送代码，而无需每次输入用户名和密码：

```bash
git push origin main
```

### 总结：
1. **生成 SSH 密钥**：使用 `ssh-keygen` 命令生成 SSH 密钥对。
2. **添加公钥到 GitHub**：将公钥复制到 GitHub 设置中的 SSH Keys。
3. **测试连接**：通过 `ssh -T git@github.com` 测试 SSH 连接。
4. **克隆仓库并配置 SSH**：使用 SSH URL 克隆仓库或修改现有仓库的远程地址。

通过这些步骤，你就可以安全地使用 SSH 链接 Git 仓库，避免每次提交时输入密码。

## git检查文件大小

要显示 **Git 暂存区**中文件的列表及其大小，可以使用以下方法：

1. **使用 `git ls-files`**

   - 命令：

     ```bash
     git ls-files -s
     ```

     此命令会显示暂存区中所有文件的信息，包括文件的大小、文件类型（如 blob）、文件权限等。

   - 示例输出：

     ```
     100644 blob d670460b4b4aece5915caf5c68d12f560a9fe3e4 25  welcome.txt
     ```

     其中第一个字段是文件权限，最后一列是文件名，中间的字段可以通过结合其他命令解析出文件大小。

2. **使用 `git cat-file` 检查文件大小**

   - 命令：

     ```bash
     git ls-files | xargs -I {} git cat-file -s {}
     ```

     此方法可以显示文件在 Git 对象库中的实际大小。

3. **其他相关命令**

   - 使用 `git status` 查看文件状态，但不包括文件大小。
   - 使用 `git diff --cached` 查看暂存区的更改内容，但文件大小需要另行解析。

这些命令可以帮助你深入了解 Git 暂存区中的文件和对应的详细信息。

## error: src refspec main does not match anyerror: failed to push some refs to 'https://github.com/ruanqingxuan/congestion_switching.git'

The error `src refspec main does not match any` typically occurs when the branch you are trying to push does not exist or has not been created locally. Here's how you can resolve it:

### Steps to Fix the Error:

1. **Verify the Current Branch Name:**

   - Run the following command to check your branch:

     ```bash
     git branch
     ```

   - If you don’t see a `main` branch, you are likely on a different branch (e.g., `master`) or haven't created a branch yet.

2. **Create and Switch to the `main` Branch (if necessary):**

   - If you need a 

     ```
     main
     ```

      branch but it doesn’t exist, create it:

     ```bash
     git checkout -b main
     ```

3. **Commit Your Changes:**

   - Ensure there are files staged for commit:

     ```bash
     git add .
     ```

   - Commit them:

     ```bash
     git commit -m "Initial commit"
     ```

4. **Push to the Remote Repository:**

   - Push the 

     ```
     main
     ```

      branch to the remote repository:

     ```bash
     git push -u origin main
     ```

5. **Check for Remote Branch Mismatches:**

   - If your remote repository is configured to use a different default branch (e.g., 

     ```
     master
     ```

     ), adjust your push command:

     ```bash
     git push -u origin master
     ```

### Common Causes of This Error:

- Attempting to push a branch (`main`) that doesn't exist locally or remotely.
- Forgetting to stage or commit changes before pushing.
- A mismatch between the default branch in the repository (`main` vs. `master`).

Following these steps should resolve the issue.

# 另一个本地仓库修改了远程仓库，本仓库想要同步远程仓库的修改怎么办

如果另一个本地仓库修改了远程仓库，而你希望将这些修改同步到你本地的仓库，可以通过以下步骤操作：

### 1. 保留本地和远程的改动 - 使用 `merge`（测试有效）

假设你有一些本地改动，并且远程仓库也有你还没有拉取的更改，你可以使用 `git merge` 将远程的更改合并到本地，并解决冲突，保留两边的改动。

#### 步骤：

1. **保存本地改动（如果有）**： 确保你本地的改动已经保存（通过 `git add` 和 `git commit`）。

2. **拉取远程仓库的最新改动**： 你需要首先拉取远程仓库的改动。在此过程中可能会遇到冲突。使用以下命令：

   ```bash
   git fetch origin
   ```

3. **合并远程改动到本地**： 使用 `git merge` 将远程的改动合并到本地。例如，如果你在 `main` 分支上工作：

   ```bash
   git merge origin/main
   ```

   这时，如果本地和远程都有改动，Git 会自动尝试合并改动。如果存在冲突，Git 会标记冲突的文件，需要你手动解决。

4. **解决冲突**： Git 会标记有冲突的文件，打开文件并修改冲突部分。Git 会在冲突的部分用如下标记来标记冲突：

   ```plaintext
   <<<<<<< HEAD
   （本地的修改）
   =======
   （远程的修改）
   >>>>>>> origin/main
   ```

   你需要手动编辑这些文件，选择或者合并两边的修改，保存文件后，执行：

   ```bash
   git add <冲突解决后的文件>
   ```

5. **提交合并后的修改**： 当所有冲突都解决后，执行：

   ```bash
   git commit
   ```

   这时你可以提供一个合并的提交信息。

6. **推送到远程仓库**： 最后，将合并后的本地修改推送到远程仓库：

   ```bash
   git push origin main
   ```

这样你就能保留本地和远程仓库的改动，完成合并。

------

### 2. 使用 `rebase` 保留两者的改动

如果你希望你的本地提交保持在远程提交之上，而不是在合并后产生一个合并提交，可以使用 `git rebase`。

#### 步骤：

1. **保存本地改动（如果有）**： 确保本地改动已经提交。

2. **拉取远程仓库的最新改动**： 拉取远程改动：

   ```bash
   git fetch origin
   ```

3. **执行 rebase 操作**： 使用 `git rebase` 将你的本地修改放到远程修改之后。例如：

   ```bash
   git rebase origin/main
   ```

4. **解决冲突**： 如果有冲突，Git 会暂停 `rebase` 操作并要求你解决冲突。解决方法与 `merge` 操作类似，打开冲突的文件，解决冲突，然后使用：

   ```bash
   git add <冲突解决后的文件>
   git rebase --continue
   ```

5. **完成 rebase**： 如果没有更多冲突，`rebase` 会继续并完成。最后，推送本地的改动到远程仓库。由于 rebase 改变了提交历史，通常需要强制推送：

   ```bash
   git push origin main --force
   ```

   **注意：** 强制推送会覆盖远程仓库的历史，谨慎操作，最好与团队成员沟通。

------

### 3. 总结

- 使用 **`git merge`**：可以保留两边的修改，并通过合并提交来整合两边的改动。
- 使用 **`git rebase`**：将本地提交放到远程提交的顶部，历史看起来更简洁，但需要解决冲突并可能需要强制推送。

### 推荐做法：

- 如果你不太关心提交历史，可以使用 **`merge`** 来合并两边的改动。
- 如果你希望提交历史更干净，选择 **`rebase`**，但注意可能会破坏远程的历史，尤其在多人合作时需要谨慎。
