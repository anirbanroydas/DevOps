Linux User and Group Management
================================

Linux/Unix operating systems have the ability to multitask in a manner similar to other operating systems. However, Linux’s major difference from other operating systems is its ability to have multiple users. Linux was designed to allow more than one user to have access to the system at the same time. In order for this multiuser design to work properly, there needs to be a method to protect users from each other. This is where permissions come in to play.


## 1. How To Add a User

- If you are signed in as the root user, you can create a new user at any by typing:
        
        $ adduser newuser

- If you are signed in as a non-root user who has been given sudo privileges:
        
        $ sudo adduser newuser

- You can also do the same things using the command `useradd` (the default command used in linux):

        $ sudo adduser newuser

- When a new user account is added to the system, the following operations are performed.

    - His/her home directory is created (/home/username by default).

    - The following hidden files are copied into the user’s home directory, and will be used to provide environment variables for his/her user session:
            
            .bash_logout
            .bash_profile
            .bashrc
    
- The useradd command utilizes a variety of variables, some of which are shown in the table below:

        # -d <home_dir>  home_dir will be used as the value for the user’s login directory 
        $ useradd <name> -d /home/<users home>

        # -e <date>   the date when the account will expire   
        $ user add <name>** -e <YYYY-MM-DD>

        # -f <inactive>   the number of days before the account expires
        $ useradd <name> -f <0 or -1>

        # -s <shell>  sets the default shell type
        $ useradd <name> -s /bin/<shell>


- You will need to set a `password` for the new user by using the `passwd` command. Note, you will need root privileges to change a user password. The syntax is as follows:
        
        $ passwd <username>
        Changing password for lmartin.
        (current) UNIX password:
        Enter new UNIX password:
        Retype new UNIX password:
        passwd: password updated successfully


## 2. How To Grant a User Sudo Privileges

If your new user should have the ability to execute commands with `root (administrative) privileges`, you will need to give the new user access to `sudo`. Let's examine two approaches to this problem: Adding the user to a pre-defined `sudo user group`, and specifying privileges on a per-user basis in sudo's configuration.

#### Add the New User to the Sudo Group

By default, `sudo` on `Ubuntu 16.04` systems is configured to extend full privileges to any user in the sudo group.

- You can see what groups your new user is in with the groups command:
        
        $ groups newuser

        # Output
        newuser : newuser

- By default, a new user is only in their own group, which is created at the time of account creation, and shares a name with the user. In order to add the user to a new group, we can use the `usermod` command:
    
        $ usermod -aG sudo newuser

    The `-aG` option here tells usermod to add the user to the listed groups.


#### Specifying Explicit User Privileges in `/etc/sudoers`

As an alternative to putting your user in the `sudo` group, you can use the `visudo` command, which opens a configuration file called `/etc/sudoers` in the system's default editor, and explicitly specify privileges on a per-user basis.

Using `visudo` is the only recommended way to make changes to `/etc/sudoers`, because it locks the file against multiple simultaneous edits and performs a sanity check on its contents before overwriting the file. This helps to prevent a situation where you misconfigure sudo and are prevented from fixing the problem because you have lost `sudo` privileges:

    $ sudo visudo



## 3. How To Delete a User

You can either use `userdel` command or `deluser` command to delete a user.

- You can delete the user itself, without deleting any of their files, by typing this as root:

        $ sudo deluser newuser

- If, instead, you want to delete the user's home directory when the user is deleted, you can issue the following command as root:

        $ sudo deluser --remove-home newuser

- If you had previously configured `sudo` privileges for the user you deleted, you may want to remove the relevant line again by typing:

        $ sudo visudo
        
        # Output
        root    ALL=(ALL:ALL) ALL
        newuser ALL=(ALL:ALL) ALL   # DELETE THIS LINE


## 4. How To View Available Users 

Every user on a Linux system, whether created as an account for a real human being or associated with a particular service or system function, is stored in a file called `/etc/passwd`.

The `/etc/passwd` file contains information about the users on the system. Each line describes a distinct user.

    $ less /etc/passwd
    root:x:0:0:root:/root:/bin/bash
    daemon:x:1:1:daemon:/usr/sbin:/bin/sh
    bin:x:2:2:bin:/bin:/bin/sh
    sys:x:3:3:sys:/dev:/bin/sh
    sync:x:4:65534:sync:/bin:/bin/sync
    games:x:5:60:games:/usr/games:/bin/sh
    . . .

## 5. How To View Available Groups

The corresponding file for discovering system groups is `/etc/group`.

    $ less /etc/group
    root:x:0:
    daemon:x:1:
    bin:x:2:
    sys:x:3:
    adm:x:4:
    tty:x:5:
    disk:x:6:
    . . .


## 6. How To Find Which Users Are Logged In

- The `w` command is a simple way to list all of the currently logged in users, their log in time, and what the command they are currently using:

        $ w
    
        19:37:15 up  5:48,  2 users,  load average: 0.33, 0.10, 0.07
        USER     TTY      FROM              LOGIN@   IDLE   JCPU   PCPU WHAT
        root     pts/0    rrcs-72-43-115-1 19:15   38.00s  0.33s  0.33s -bash
        demoer   pts/1    rrcs-72-43-115-1 19:37    0.00s  0.47s  0.00s w

- An alternative that provides similar information is `who`:

        $ who





