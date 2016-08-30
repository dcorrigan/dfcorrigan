---
title: Dirt Cheap Daily Backups
date: 2016-08-27 21:55 UTC
tags:
  - linux
  - cloud
---

Like a lot of people, I'm arbitrary about which monthly services I'll pay for. I'll pay five to ten dollars a month each for a few streaming TV services, but I balk at paying that much for a backup solution. I realize this is silly, but it's not about to change. Instead, I worked out a cheap storage method I rarely have to think about and costs less than a dollar a month.

It involves a tool called [rclone](http://rclone.org/) and [Google Nearline Storage](https://cloud.google.com/storage-nearline/). First, you need a Google developer's account. Go get one [here](https://console.cloud.google.com). Enter your billing info, yadda yadda, and create a new cloud storage bucket. Name it whatever you feel like, but under "storage class" be sure to select "Nearline." This type of storage is for infrequently accessed data. You would incur extra cost if you were pushing and pulling from it constantly, but it's great for daily backups. It bills at one cent per gig per month. Unless you're backing up a giant media library, this is bound to be cheaper than any other service provider.

Next you need to install rclone. Rclone is conceptually simple: it's rsync, but for cloud services. It can handle AWS, Dropbox, Google Drive, and Google cloud storage (those last two are distinct; careful not to confuse them while configuring things). The documentation is clear and useful, so follow the [install guide](http://rclone.org/install/) and then the [setup guide for Google cloud](http://rclone.org/googlecloudstorage/). Most of the work is now done.

You most likely want the [sync command](http://rclone.org/commands/rclone_sync/) for backups. In my case, I'm backing up my `~/Documents` directory to a Nearline bucket, so my command looks like this:

```
rclone sync ~/Documents gbackup:dfc-backup
```

In this case, "gbackup" is what I've named the remote cloud project registed with rclone and "dfc-backup" is the name of the specific Nearline bucket.

Finally, you just need to register the backup as a cron job. On many linux sysems like Ubuntu, it's as simple as putting the sync command in a script in `/etc/cron.daily/`. Scripts in that directory will be run once a day by cron. In my case, it's in `/etc/cron.daily/dfc-backup` with the following content:

```
su dan -c "rclone sync ~/Documents gbackup:dfc-backup; echo `date` > ~/backups.list"
```

Cron jobs are executed as root, but I built rclone and configured my cloud storage as my regular user. As you can see, I have the script masquerade as "dan" in order to run. I also have the script dump the time it finished into a text file so I can check the last backup at a glance. Depending on your system, you might need to register the cron job with anacron.

There you have it. I don't keep a ton of data, so my monthly bill is around 20 cents at the moment.
