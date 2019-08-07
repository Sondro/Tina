#include <stdbool.h>

#include <stdlib.h>
#include <stdio.h>

#include "tina.h"


void err(const char* message){
	fprintf(stderr, "Tina err: %s\n", message);
}

static uintptr_t coro_body(tina* coro, uintptr_t value){
	printf("coro_body() enter\n");
	
	for(unsigned i = 0; i < 10; i++){
		printf("coro_body(): %u\n", i);
		tina_yield(coro, true);
	}
	
	printf("coro_body() return\n");
	return false;
}

int main(int argc, const char *argv[]){
	tina_err = err;
	
	void* buffer = malloc(1024*1024);
	tina* coro = tina_init(buffer, 1024*1024, coro_body, NULL);
	
	while(tina_resume(coro, 0)){}
	printf("Success!\n");
	
	printf("Resuming again will crash...\n");
	tina_resume(coro, 0);
	
	return EXIT_SUCCESS;
}
