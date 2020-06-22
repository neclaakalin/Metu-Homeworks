all:
	gcc main.c -o server
	gcc prey.c -o prey
	gcc hunter.c -o hunter
server:
	gcc main.c -o server
hunter:
	gcc hunter.c -o hunter
prey:
	gcc prey.c -o prey
clean:
	rm -rf prey
	rm -rf hunter
	rm -rf server
run:
	./server < inp
