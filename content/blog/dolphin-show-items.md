---
title: "A Tiny Dolphin Bug"
description: "A tiny, annoying bug in KDE's Dolphin file manager"
date: 2024-05-22T23:14:07-07:00
tags:
  - kde
  - linux
  - programming
---

Just wanted to write a blog post about a bug I found in Dolphin quite a while ago, which I've reported here: https://bugs.kde.org/show_bug.cgi?id=448188.

A common action that applications might want to do is to open up a folder in whatever file manager you happen to use. This can be used to show you where, say, a file you just downloaded is, or where exactly the file you're editing in your text editor is. Often times, for these tasks, it's benificial to actually open up that folder and select exactly the file you want the user to pay attention to. That's exactly what the `ShowItems` method in the `org.freedesktop.FileManager1` DBus interface is for!

If you're unaware, DBus is a fancy way for applications on Linux to communicate with one another. In this case, file managers can implement this interface so applications know how to perform this action, and have it work across distros and desktop environements. You can find more info on this specific interface and method here: https://www.freedesktop.org/wiki/Specifications/file-manager-interface/.

As an aside, why don't desktop portals have a way of doing this? We can tell the file manager to open up to a specific place, yes, but not a specific folder. It seems that for Dolphin though, it suffers the same bug I'll describe below when you show a folder through portals too. Perhaps this bug is already reported under there, I'll have to look.

The actual bug happens when you try and show a folder when Dolphin is already open, and it needs to open up a new tab to show you this location you tell it to. If the file you're trying to show isn't in a folder that's already open, instead of opening up that folder in the existing Dolphin window, it will instead create a new Dolphin window, sometimes with an old Dolphin state, and show you the file there!

As you can expect, this is quite annoying. It's also been quite a long standing bug for me, and I'm not sure if it's due to a configuration error on my end at this point. I'll be looking for more bug reports of this issue, but for now, I'll simply cope with this bug and maybe try and fix it some day myself.
