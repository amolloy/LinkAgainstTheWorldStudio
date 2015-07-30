# Link Against the World

This README is currently more like a journal for the development of this project.

_30 July 2015_

My oldest son, currently seven, is a huge fan of the Zelda series of
video games. Knowing that his dear old dad is a programmer in the video game industry, he's been asking me about making his own Zelda-like game for months. Having reached a good breaking point between my several other personal projects, I decided it was finally time to do something about it with him. This project is the result of that.

My son's requirements are:

* 3D (Ocarina of Time)-style is preferable, but 2D (Minish Cap) is OK.
* Re-using real Zelda assets is OK (we're never going to sell this thing).
* Must have dungeons and boss battles!

That's pretty much it. I've decided I'm not ready to take on creating and working with 3D at this point, so this will be a 2D-style game.

So, here's the thing. I've been working in the video game industry for more than a decade, as a programmer for most of that time. But I have never actually created a game on my own from the ground up. I don't even have many of the usual set of aspiring-game-programmer projects. The closest I have is a program which allows you to explore Quake 2 maps which probably doesn't even compile with modern C++. I decided this was as good an excuse as any to rectify that.

And, because I wanted this to be as difficult for me as possible, I also decided it was time I finally give Swift another try. So this project will be written in Swift. I am going to attempt to write it in as idiomatic Swift as possible, but... I won't always know what idiomatic Swift looks like and, perhaps more importantly at this point, idiomatic Swift may not even really exist yet. Everyone is still figuring it out. So if any Objective-C-isms (or, god forbid, C++-isms) pop up, that's why.

All of that is a long winded way to say:

![I HAVE NO IDEA WHAT I'M
DOING](http://i1.kym-cdn.com/photos/images/original/000/234/765/b7e.jpg)

I should also note that I am well aware of pre-existing projects for making Zelda-like games. Here are a few I've come across:

* [Solarus](http://www.solarus-games.org)
* [OpenZelda](http://www.openzelda.net)

I will likely use these as reference from time to time, but since I am doing this as much for my own education and betterment as for a project to do with my son, I do not intend to use them directly.

At this point I've just started working out a plan. I've decided a reasonable first step is to get a map loaded and drawn on the screen, and be able to scroll it around. Rather than invent my own tile-based map file format, I've decided to start with the FMP format used by [Mappy](http://tilemap.co.uk/mappy.php). This format has a number of advantages:

* It's been around for ages and is reasonably straightforward.
* There are numerous map editors which can produce FMP files, and there are several example FMP maps available which I can use for testing.
* The format is documented, sort of. A lot of that documentation is "see the code," but the code is pretty straightforward C so that's not a problem.
* It's not XML-based.
* One of those few "game programmer projects" I actually have worked on was an implementation of a FMP map loader, so I have experience with it.

I believe this will allow me to get to a first draw relatively quickly. Since the client is a seven year old, I imagine having the ability to create and scroll around a Zelda-like tile-based map will be a plenty impressive first draw.
