Necla Nur AKALIN 2171148

Scripts e_d.py, e_r3.py and e_s.py should be ran after setting the configurations for each of the experiments inside the corresponding nodes with the following code in which X stands for the e_d, e_r3 and e_s separately:

python X.py

The order to run the scripts is as follows: e_d.py, e_r3.py, e_s.py

tc/netem commands are used to apply network emulation delay to the system.

If the command is run for the first time on an interface, "add" version should be used, otherwise "add" must be replaced with "change".

Experience 1:

For node s, the following command should be used:

# tc qdisc add dev eth1 root netem delay 20ms 5ms distribution normal

For node r3,  the following commands should be used:

# tc qdisc add dev eth1 root netem delay 20ms 5ms distribution normal
# tc qdisc add dev eth2 root netem delay 20ms 5ms distribution normal

For node d,  the following command should be used:

# tc qdisc add dev eth2 root netem delay 20ms 5ms distribution normal

Experience 2:

For node s, the following command should be used:

# tc qdisc change dev eth1 root netem delay 40ms 5ms distribution normal

For node r3,  the following commands should be used:

# tc qdisc change dev eth1 root netem delay 40ms 5ms distribution normal
# tc qdisc change dev eth2 root netem delay 40ms 5ms distribution normal

For node d,  the following command should be used:

# tc qdisc change dev eth2 root netem delay 40ms 5ms distribution normal

Experience 3:

For node s, the following command should be used:

# tc qdisc change dev eth1 root netem delay 50ms 5ms distribution normal

For node r3,  the following commands should be used:

# tc qdisc change dev eth1 root netem delay 50ms 5ms distribution normal
# tc qdisc change dev eth2 root netem delay 50ms 5ms distribution normal

For node d,  the following command should be used:

# tc qdisc change dev eth2 root netem delay 50ms 5ms distribution normal

After each of experiments, the costs between s-r3 is written to the file sDelay.txt inside the s node, and the costs between r3-d is written to the file r3Delay.txt inside the r3 node.