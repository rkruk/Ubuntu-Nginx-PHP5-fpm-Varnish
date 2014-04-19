**                                                                     ubuntu-nginx-happiness**

**                                                          =============================**

<br />
<b>Step by step:</b>  console commands, config files and real life examples for setting up the web server based on <b>Ubuntu</b> + <b>NGINX</b> + <b>Varnish</b>.

<i>Additionally, I've added my 'reasonable speed' and efficiency optimisations for small (to medium) size servers (256mb to 2gb processor + 256mb to 3gb RAM).</i>

<i>It is compatible with Ubuntu (tested on 13.04, 13.10 and 14.04), Debian (testing line)- but most of the workflow after carefully read and adapted, should work on any Linux web server.</i>
**   **
**                                                                                                     **

This is a cheat sheet I use every single time for my own purposes, when I'm setting up a production web server. As it is rather not exciting and time consuming task - I have decided to make a small repo with all those boring things as configs and steps - necessary to set thigs up and running.. without digging through various manuals, wikis, forums.

Usually I use cloud based virtual servers but it should* works just for any working web server based on Ubuntu.
<br />
<br />
<i> * - Please use your own brain! And don't blindly copy and paste commands to your terminal - for your own safety. <i>
**                                                                                                     **
**   **

<br />
**                              How you should read files hierarchy:**
<b> How you should read files hierarchy: </b>
<br />

<b> / </b>    (root)

 |

  ---&gt; /etc

 |        |

 |        ---&gt; /etc/nginx

 |                     |

 |                     ---&gt; /etc/nginx/html (for 50.. sites)

 |                     ---&gt; /etc/nginx/sites-available (template configs for websites)

 |                     ---&gt; /etc/nginx/sites-enabled (enabled template configs)

 |

 ---&gt; /var

        |

        ---&gt;/var/www (here are dragons)
