# Repository to test automation of setting up Jenkins, with a view to setting up Jenkins to trigger a build when pushing to the repo using GitHub.

### Fully automated with provisioning :innocent: :heart_eyes:

## Step by Step guide:

- make sure Jenkins is running:
1. vagrant up

### Ideally, you automate the next few steps with provision.sh file.
2. install nginx:

        sudo apt-get update
        sudo apt-get install nginx -y
        sudo systemctl start nginx

3. install java:

        sudo apt-get update
        sudo apt install openjdk-8-jdk -y

4. install nodejs:

        sudo apt-get install curl -y
        curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
        sudo apt-get install nodejs -y

5. install jenkins:

        wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -
        sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
        sudo apt update
        sudo apt install jenkins -y

To check that jenkins is running:

        systemctl status jenkins

This should show something like:
![Jenkins_status](https://miro.medium.com/max/919/1*sLQs1alHydHfGDehavl83w.png)

6. We need to open the ports necessary, so we can get round the firewall:

        sudo ufw allow OpenSSH
        sudo ufw enable
        sudo ufw allow 8080

You can check the status of your firewall by executing:

        sudo ufw status

it should show 4 objects in this list.

7. Now we need to install ngrok. Please make sure you have this downloaded to your host device from: https://ngrok.com/.

You'll have to follow the steps on their site to unzip it, check that it runs in any terminal with ./ngrok help.

You'll have to make an account with ngrok (recommend linking with github), and get the auth key from the dashboard there, follow the instructions to connect this via your terminal.

![ngrok.install](https://miro.medium.com/max/835/1*l7XNHpi0hDEYhnv301zmzQ.png)

But don't open the port on 80!

Then once you've done this, go back to your vagrant ssh window and install it there:

        sudo npm i -g ngrok --unsafe-perm=true --allow-root

Again, you might have to connect your account using the auth key method (think I had to do it again inside the ssh terminal, but either way it can't hurt to do it again)

Check that ngrok works in your terminal with ngrok -h, if it doesn't there might be some problem with the installation?

NOTE: THIS PROCESS CAN BE FULLY AUTOMATED USING PROVISIONING! It can be a bit sticky though. But in theory, you can have steps 2-7 done automatically when you vagrant up.

8. Now we have jenkins running with everything we need (nginx, java, nodejs and particularly ngrok - which allows us to open a local port to the wider internet).

Go to the local jenkins port (probably development.local:8080, or whatever you named it in your vagrant file), and it'll ask for a password. You can get this password by entering into your terminal

        sudo cat /var/lib/jenkins/secrets/initialAdminPassword

which will return the password required to gain acces to jenkins. Set up your user as usual and proceed.

9. We can now proceed to try and set up the link between your virtual machine, GitHub and Jenkins.

With ngrok now able to run, we can open a tunnel to the port where jenkins is set up. In your ssh terminal, do this with the command:

        ngrok http 8080

This will take you to a different screen, opening that single port on your local domain to the wider internet and allowing connection to GitHub.

Should look something like this:
![ngrok.open_port](https://miro.medium.com/max/910/1*i27GJW-YLn4ik9kN8HKRxw.png)

In that new screen in your terminal, you will see a URL next to "forwarding", you're going to want to copy that link (up to before the arrow), this is essentially a proxy URL for hosting your local domain's 8080 port on the wider web. We're going to need it to bounce things around a bit!

This window will also provide you with updates of whenever something is sent through it, perhaps a git request to push to the master?? :taco:

IMPORTANT: DO NOT LEAVE THIS WINDOW, ALWAYS HAVE YOUR BASH WINDOW OPEN ON IT. IF YOU LEAVE IT, THE CONNECTION FROM YOUR LOCAL DOMAIN TO THE WIDER WEB WILL BE LOST AND YOU WILL HAVE TO RE-ENTER IT. If you do leave this window and have to re-enter, you will have to change settings in both Jenkins and Github Webhooks to reflect the change in key. In summary:

### Don't leave the port open screen on bash, once you've entered it!

10. Now, go to your GitHub repository that you'd like to connect to Jenkins and head to settings (top right ish). Then, head to webhooks section from the left side menu. We're going to want to add a new webhook, and then add the URL as whatever is displayed back in your ngrok terminal from part 8. Then, before exiting, add /github-webhook/. The final product should look something like:

        http://[random_key].eu.ngrok.io/github-webhook/

The content should be "application/x-..." form, but I'm not certain how much this matters. Then you want to enable SSL verif, have just the push event triggering the webhook, then finally update it.

Ideally, it has a nice green tick next to it also. But that might not be the case if other things aren't set up properly.

Ideally, something like this, bar the change in ssh key:
![webhook-setup](https://miro.medium.com/max/674/1*LBgybSiwTY-umPSJ7fvDBA.png)

11. Next up, we need to play around with some Jenkins settings.

Go into Jenkins on the browser, head to Manage Jenkins, then to Manage Plugins. We're going to want to install the GitHub Pull Request Builder, and the GitHub interaction plugin.

12. Now these are installed (you may have to restart Jenkins), we can go to Manage Jenkins, then Configure System.

Here, scroll down to GitHub Pull Requests, and copy the link of your connected repository into the Published Jenkins URL section.

![Published_Jenkins_URL](https://slathia15472244374.files.wordpress.com/2018/10/31.png?resize=810%2C455)

Next, enter your authentication information so it has access to your GitHub.

Finally, go and make a new project in the Jenkins home page, connecting it to your repository correctly, with the authentication necessary.

Under Build Triggers section in set-up, make sure that

        GitHub hook trigger got GITScm polling

is checked off. This means that this job will execute every time a commit is made in your github repository.

![github_trigger](https://slathia15472244374.files.wordpress.com/2018/10/14.png?resize=810%2C455)

This is where, theoretically, we could add steps to do builds on jenkins, like execute a shell. No need to play around with this yet, but we might get to a stage where we can implement tests or something as a triggered build when testing.

Click Build now to execute the build. The first instance will carry out a build, but the only way to test this is to try and do a commit and push on your bash terminal.

If you've carried out all these steps, it should work like a charm and you should see builds every time you commit and push changes in git bash command line.
