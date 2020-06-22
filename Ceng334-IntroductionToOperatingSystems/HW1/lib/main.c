#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <limits.h>
#include <poll.h>
#include <sys/socket.h>
#include <sys/wait.h>
#include <sys/select.h>
#include "logging.h"
#include "message.h"

#define PIPE(fd) socketpair(AF_UNIX, SOCK_STREAM, PF_UNIX, fd)

typedef struct _str
{
	char x[1000];
} str;

int starting_bid, minimum_increment, number_of_bidders, current_bid, i, j;
int number_of_args, bidder_arg;
int **bidderFds;
int *bidderDelays;
char ***bidderArgs;
int **arg_backup;
int aliveBidder;
int current_id = 0;

str *bidder_exec;

	/*********************** LOGGING.C BELOW ***********************/
void print_output(oi* data, int client_id) {
    printf("COMM: 1 CID: %d TYPE: %d PID: %d ", client_id, data->type, data->pid);
    if (data->type == SERVER_CONNECTION_ESTABLISHED)
        printf("SBID: %d CBID: %d MI: %d \n", data->info.start_info.starting_bid, data->info.start_info.current_bid, data->info.start_info.minimum_increment);
    else if (data->type == SERVER_BID_RESULT)
        printf("RESULT: %d CBID: %d \n", data->info.result_info.result, data->info.result_info.current_bid);
    else
        printf("WINNER: %d WBID: %d \n", data->info.winner_info.winner_id, data->info.winner_info.winning_bid);
}

void print_input(ii* data, int client_id) {
    printf("COMM: 0 CID: %d TYPE: %d PID: %d ", client_id, data->type, data->pid);
    if (data->type == CLIENT_CONNECT)
        printf("DELAY: %d \n", data->info.delay);
    else if (data->type == CLIENT_BID)
        printf("BID: %d \n", data->info.bid);
    else
        printf("STATUS: %d \n", data->info.status);
}

void print_server_finished(int winner, int winning_bid) {
    printf("COMM: 2 W: %d WB: %d\n", winner, winning_bid);
}

void print_client_finished(int client_id, int status, int status_match) {
    printf("COMM: 3 CID: %d STATUS: %d SM: %d\n", client_id, status, status_match);
}
	/****************** END OF THE LOGGING.C FILE ******************/

int main() {

	/************************ INITIALIZATION ************************/
	// get the first input: starting_bid, minimum_increment and number_of_bidders
	scanf("%d %d %d", &starting_bid, &minimum_increment, &number_of_bidders);
	current_bid = starting_bid;

	// allocate an array to store the bidders indeces
	pid_t *bidderProcess = malloc(number_of_bidders*sizeof(pid_t));
	struct pollfd bidderPoll[number_of_bidders];
	bidderFds = malloc(number_of_bidders*sizeof(int *));
	bidderDelays = malloc(number_of_bidders*sizeof(int));

	// allocate zeros to bidder Fd's
	for(i = 0; i < number_of_bidders; i++) {
		bidderFds[i] = calloc(2, sizeof(2));
	}

	// take the argv of bids: number_of_args, bidder_arg
	bidderArgs = malloc(number_of_bidders*sizeof(char **));
	arg_backup = malloc(number_of_bidders*sizeof(int *));
	bidder_exec = malloc(number_of_bidders*sizeof(str));

	for(i = 0; i < number_of_bidders; i++) {
		scanf("%s", bidder_exec[i].x);
		scanf("%d", &number_of_args);

		bidderArgs[i] = malloc(sizeof(char *)*(number_of_args+2));
		arg_backup[i] = malloc(sizeof(int)*(number_of_args));
		bidderArgs[i][0] = malloc(sizeof(char)*30);
		strcpy(bidderArgs[i][0], bidder_exec[i].x);

		for(j = 0; j < number_of_args; j++) {
			scanf("%d", &(arg_backup[i][j]));
			bidderArgs[i][j+1] = malloc(sizeof(char)*30);
			snprintf(bidderArgs[i][j+1],sizeof(bidderArgs[i][j+1]),"%d",arg_backup[i][j]);
		}
		bidderArgs[i][j+1]=NULL;
	}

	// create pipes for every bidder
	for(i = 0; i < number_of_bidders; i++) {
		PIPE(bidderFds[i]);

		// create children
		pid_t pid = fork();
		if (pid < 0) { // this should not be the case
			fprintf(stderr, "ERROR: Cannot fork the child. \n");
			fflush(stderr);
		}
		else if (pid == 0) { // it is the child
			for(j = 0; j < number_of_bidders; j++) {
				if(i != j) {
					close(bidderFds[j][0]);
					close(bidderFds[j][1]);
				}
			}
			close(bidderFds[i][0]); 	// close read end
			dup2(bidderFds[i][1], 0);
			dup2(bidderFds[i][1], 1); 	// DANGER HERE

			if(execvp(bidder_exec[i].x, bidderArgs[i]) < 0) {
				printf("ERROR: Couldn't execute the bidder. i: %d\n", i);
			}
		}
		bidderProcess[i] = pid;


		// Get and send initial messages and delays
		cm clientMessage;
		if(read(bidderFds[i][0], &clientMessage, sizeof(clientMessage)) == -1) {
			printf("ERROR: Couldn't read the initial message on bidder: %d.\n", i);
		}

		else {
			ii inputMessage;
			inputMessage.type = CLIENT_CONNECT;
			inputMessage.pid = bidderProcess[i];
			inputMessage.info = clientMessage.params;
			bidderDelays[i] = clientMessage.params.delay;

			print_input(&inputMessage, i);
		}

		sm serverMessage;

		serverMessage.message_id = SERVER_CONNECTION_ESTABLISHED;
		serverMessage.params.start_info.client_id = i;
		serverMessage.params.start_info.current_bid = current_bid;
		serverMessage.params.start_info.starting_bid = starting_bid;
		serverMessage.params.start_info.minimum_increment = minimum_increment;

		if(write(bidderFds[i][0], &serverMessage, sizeof(serverMessage)) == -1) {
			printf("ERROR: Couldn't send the initial message to bidder: %d.\n", i);
		}
		else {
			oi outputMessage;
			outputMessage.type = SERVER_CONNECTION_ESTABLISHED;
			outputMessage.pid = bidderProcess[i];
			outputMessage.info = serverMessage.params;
			print_output(&outputMessage, i);
		}
	}
	/**************** END OF THE INITIALIZATION PART ****************/

	for (i=0;i<number_of_bidders;i++)
	{
		bidderPoll[i].fd=bidderFds[i][0];
		bidderPoll[i].events=POLLIN;
		bidderPoll[i].revents=0;
	}

	aliveBidder = number_of_bidders;

	int min_delay;

	if(bidderDelays[0]) {
		min_delay = bidderDelays[0];
		for(i = 1; i < number_of_bidders; i++) {
			if(bidderDelays[i] < min_delay) {
				min_delay = bidderDelays[i];
			}
		}
	}
	else {
		min_delay = 0;
	}

	while(aliveBidder) {
		if(poll(bidderPoll, number_of_bidders, min_delay) < 0) {
			printf("ERROR: Couldn't pool.\n");
		}
		else {
			for(i = 0; i < number_of_bidders; i++) {
				if(bidderPoll[i].revents && POLLIN) {

					cm clientMessage;
					read(bidderFds[i][0], &clientMessage, sizeof(clientMessage));

					ii inputMessage;
					inputMessage.type = clientMessage.message_id;
					inputMessage.pid = bidderProcess[i];
					inputMessage.info = clientMessage.params;

					print_input(&inputMessage, i);

					// Determine the type and the response of the message
					if(clientMessage.message_id == CLIENT_CONNECT) {
						printf("WARNING: Client_connect shouldn't be the case.\n");
					}
					else if(clientMessage.message_id == CLIENT_BID) {
						if(clientMessage.params.bid < starting_bid) {
							// send BID_LOWER_THAN_STARTING_BID
							sm serverMessage;

							serverMessage.message_id = SERVER_BID_RESULT;
							serverMessage.params.result_info.result = BID_LOWER_THAN_STARTING_BID;
							serverMessage.params.result_info.current_bid = current_bid;
 
							if(write(bidderFds[i][0], &serverMessage, sizeof(serverMessage)) == -1) {
								printf("ERROR: Couldn't send the i message to bidder: %d.\n", i);
							}
							else {
								oi outputMessage;
								outputMessage.type = serverMessage.message_id;
								outputMessage.pid = bidderProcess[i];
								outputMessage.info = serverMessage.params;
								print_output(&outputMessage, i);
							}
						}
						else if(clientMessage.params.bid < current_bid) {
							// send BID_LOWER_THAN_CURRENT
							sm serverMessage;

							serverMessage.message_id = SERVER_BID_RESULT;
							serverMessage.params.result_info.result = BID_LOWER_THAN_CURRENT;
							serverMessage.params.result_info.current_bid = current_bid;
 
							if(write(bidderFds[i][0], &serverMessage, sizeof(serverMessage)) == -1) {
								printf("ERROR: Couldn't send the message to bidder: %d.\n", i);
							}
							else {
								oi outputMessage;
								outputMessage.type = serverMessage.message_id;
								outputMessage.pid = bidderProcess[i];
								outputMessage.info = serverMessage.params;
								print_output(&outputMessage, i);
							}
						}
						else if((clientMessage.params.bid - current_bid) < minimum_increment) {
							// send BID_INCREMENT_LOWER_THAN_MINIMUM
							sm serverMessage;

							serverMessage.message_id = SERVER_BID_RESULT;
							serverMessage.params.result_info.result = BID_INCREMENT_LOWER_THAN_MINIMUM;
							serverMessage.params.result_info.current_bid = current_bid;
 
							if(write(bidderFds[i][0], &serverMessage, sizeof(serverMessage)) == -1) {
								printf("ERROR: Couldn't send the message to bidder: %d.\n", i);
							}
							else {
								oi outputMessage;
								outputMessage.type = serverMessage.message_id;
								outputMessage.pid = bidderProcess[i];
								outputMessage.info = serverMessage.params;
								print_output(&outputMessage, i);
							}

						}
						else {
							// send BID_ACCEPTED
							current_bid = clientMessage.params.bid;
							current_id = i;

							sm serverMessage;

							serverMessage.message_id = SERVER_BID_RESULT;
							serverMessage.params.result_info.result = BID_ACCEPTED;
							serverMessage.params.result_info.current_bid = current_bid;
 
							if(write(bidderFds[i][0], &serverMessage, sizeof(serverMessage)) == -1) {
								printf("ERROR: Couldn't send the message to bidder: %d.\n", i);
							}
							else {
								oi outputMessage;
								outputMessage.type = serverMessage.message_id;
								outputMessage.pid = bidderProcess[i];
								outputMessage.info = serverMessage.params;
								print_output(&outputMessage, i);
							}
						}
					}
					else if(clientMessage.message_id == CLIENT_FINISHED) {

						// Send and print the response
						aliveBidder--;
						if(!aliveBidder) {
							goto quit;
						}
					}
				}
			}
		}
	}

	quit:

	print_server_finished(current_id, current_bid);

	for(i = 0; i < number_of_bidders; i++) {

		sm serverMessage;

		serverMessage.message_id = SERVER_AUCTION_FINISHED;
		serverMessage.params.winner_info.winner_id = current_id;
		serverMessage.params.winner_info.winning_bid = current_bid;
 
		if(write(bidderFds[i][0], &serverMessage, sizeof(serverMessage)) == -1) {
			printf("ERROR: Couldn't send the initial message to bidder: %d.\n", i);
		}
		else {
			oi outputMessage;
			outputMessage.type = serverMessage.message_id;
			outputMessage.pid = bidderProcess[i];
			outputMessage.info = serverMessage.params;
			print_output(&outputMessage, i);
		}
	}

	for(i = 0; i < number_of_bidders; i++) {

		int old_status;
		waitpid(bidderProcess[i], &old_status, 0);
		old_status = WEXITSTATUS(old_status);

		kill(bidderProcess[i], SIGTERM);
		int status;
		waitpid(bidderProcess[i], &status, 0);
		int exit_status = WEXITSTATUS(status);

		close(bidderFds[i][0]);
		close(bidderFds[i][1]);
		int is_match;
		if(exit_status == old_status) {
			is_match = 1;
		}
		else {
			is_match = 0;
		}
		print_client_finished(i, exit_status, is_match);
	}

	return 0;
}