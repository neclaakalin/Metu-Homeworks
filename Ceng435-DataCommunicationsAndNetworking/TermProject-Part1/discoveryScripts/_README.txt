Necla Nur AKALIN 2171148

In order to set the initial conditions to the nodes r1 and r2, configureR1.sh and configureR2.sh should be ran. After sending these scripts into nodes, one can run the scripts with the following codes:

For node r1:

chmod +x configureR1.sh
./configureR1.sh

For node r2:

chmod +x configureR2.sh
./configureR2.sh

After sending python codes(s.py, r1.py, r2.py, r3.py, d.py) to corresponding nodes, you should run the codes with an order s, d, r2, r3 and r1. You can basically run the scripts with the following code in which X stands for s, d, r1, r2 and r3 separately:

python X.py

After running the python scripts, it will take 300 seconds for clients(r1, r2 and r3) to finish their jobs and print out the total cost before division and total cost(i.e. average cost) of the links they're connected to.

You can achieve all of the costs that every message took(1000 messages) in the .txt files created inside the nodes, which are named as follows:

Inside r1: r1_to_s_costs.txt, r1_to_r2_costs.txt, r1_to_d_costs.txt
Inside r2: r2_to_s_costs.txt, r2_to_d_costs.txt
Inside r3: r3_to_s_costs.txt, r3_to_r2_costs.txt, r3_to_d_costs.txt

There's not a timeout nor a keyboard interruption functionalities put inside the scripts for servers(s, d and r2). Thus, unless you terminate the python script by closing the window, servers won't going to terminate themselves and they will keep listening for incoming messages.