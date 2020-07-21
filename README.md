# hellomario

## Example in assembly on how to initialize stuff and draw a sprint on screen for the Nintendo Entertainment System (NES)

This code is a rip-off from the guide made by Michael Chiaramonte at [THIS VIDEO](https://www.youtube.com/watch?v=LeCGYp0JWok).

Just for fun (and knowledge, of course), I've started studying how old-school consoles hardware architecture were designed and games were programmed, so this is the "Hello World" that I found interesting to write on my own.

It's been quite nice since I've brushed up my rusty-as-hell assembly skills and have also learned how the 6502 MCU works as a result.

Dependencies:

- cc65 compiler (https://cc65.github.io/)

On any Debian-based distro, just run: `sudo apt install cc65`
Anywhere else, it's on you.

To compile, just run the `make.sh` script.
The `clear.sh` script will remove compiled files.
