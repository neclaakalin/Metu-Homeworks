#include "Bank.h"

Bank::Bank(){
 	this->_bank_name = "not_defined";
 	this->_user_count = 0;
 	this->_users = nullptr;
}

Bank::Bank(std::string bank_name, Account* const users, int user_count){
	this->_bank_name = bank_name;
 	this->_user_count = user_count;
 	this->_users = new Account [this->_user_count];
 	for(int i = 0; i < user_count; i++) {
 		this->_users[i] = users[i];
	}
}

// Take A LOOK //
Bank::~Bank(){
}

Bank::Bank(const Bank& rhs){
	this->_bank_name = rhs._bank_name;
	this->_user_count = rhs._user_count;
	this->_users = new Account [this->_user_count];
	for(int i = 0; i < rhs._user_count; i++) {
		this->_users[i] = rhs._users[i];
	}
}

Bank& Bank::operator+=(const Bank& rhs){
	int old_count = this->_user_count;
	Account* old_arr = this->_users;
	int total = 0;
	for(int i = 0; i < old_count; i++) {
		for(int j = 0; j < rhs._user_count; j++) {
			if(this->_users[i] == rhs._users[i]) {
				total++;
			}
		}
	}
	this->_users = new Account [old_count+total];
	for(int i = 0; i < old_count; i++) {
		this->_users[i] = old_arr[i];
	}

	int i;
	int k = 0;
	for(int j = 0; j < rhs._user_count; j++) {
		for(i = 0; i < old_count; i++) {
			if(this->_users[i] == rhs._users[j]) {
				this->_users[i] += rhs._users[j];
				break;
			}
		}
		if(i == old_count) {
			this->_users[old_count+k] = rhs._users[j];
			k++;
		}
	}

	return *this;
}

Bank& Bank::operator+=(const Account& new_acc){
	int i;
	for(i = 0; i < this->_user_count; i++) {
		if(this->_users[i] == new_acc) {
			break;
		}
	}
	if(i < this->_user_count) {
		Account* old_arr = this->_users;
		this->_users = new Account [this->_user_count+1];
		for(int j = 0; j < this->_user_count; j++) {
			this->_users[j] = old_arr[j];
		}
		this->_users[this->_user_count] = new_acc;
		this->_user_count++;
	}
	else if(i == this->_user_count) {
		for(int i = 0; i < this->_user_count; i++) {
			if(this->_users[i] == new_acc) {
				this->_users[i] += new_acc;
				break;
			}
		}
	}
	return *this;
}

Account& Bank::operator[](int account_id){
	int i;
	std::cout << "bel: " << account_id << "leng: " << this->_user_count << std::endl;
	for(i = 0; i < this->_user_count; i++) {
		if(this->_users[i] == account_id) {
			std::cout << "after bel: " << std::endl;
			return this->_users[i];
		}
	}
	return *(this->_users);
}

std::ostream& operator<<(std::ostream& os, const Bank& bank) {
	int eligible_user_count = 0;
	double bank_balance = 0;
	double blnc = 0;
	double blnc_before = 0;

	for(int i = 0; i < bank._user_count; i++) {
		bool* negs_true = new bool [12];
		bool is_eligible = true;
		for(int j = 0; j < 12; j++) {
			blnc_before = blnc;
			struct tm time;
			if(j == 0) {
				strptime("2019-1-31 23:59:59", "%Y-%m-%d %H:%M:%S", &time);
			}
			else if(j == 1) {
				strptime("2019-2-28 23:59:59", "%Y-%m-%d %H:%M:%S", &time);
			}
			else if(j == 2) {
				strptime("2019-3-31 23:59:59", "%Y-%m-%d %H:%M:%S", &time);
			}
			else if(j == 3) {
				strptime("2019-1-30 23:59:59", "%Y-%m-%d %H:%M:%S", &time);
			}
			else if(j == 4) {
				strptime("2019-1-31 23:59:59", "%Y-%m-%d %H:%M:%S", &time);
			}
			else if(j == 5) {
				strptime("2019-1-30 23:59:59", "%Y-%m-%d %H:%M:%S", &time);
			}
			else if(j == 6) {
				strptime("2019-1-31 23:59:59", "%Y-%m-%d %H:%M:%S", &time);
			}
			else if(j == 7) {
				strptime("2019-8-31 23:59:59", "%Y-%m-%d %H:%M:%S", &time);
			}
			else if(j == 8) {
				strptime("2019-9-30 23:59:59", "%Y-%m-%d %H:%M:%S", &time);
			}
			else if(j == 9) {
				strptime("2019-10-31 23:59:59", "%Y-%m-%d %H:%M:%S", &time);
			}
			else if(j == 10) {
				strptime("2019-11-30 23:59:59", "%Y-%m-%d %H:%M:%S", &time);
			}
			else if(j == 11) {
				strptime("2019-12-31 23:59:59", "%Y-%m-%d %H:%M:%S", &time);
			}
			
			//strptime("2019-11-12 23:59:59", "%Y-%m-%d %H:%M:%S", &tm);
			//tm* time = generateTm(j);
			time_t end = mktime(&time);
			blnc = bank._users[i].balance(end);
			double diff = blnc - blnc_before;
			bank_balance+=diff;
			if(blnc < blnc_before) {
				negs_true[i] = true;
			}
			else {
				negs_true[i] = false;
			}
		}
		for(int j = 0; j < 11; j++) {
			if(negs_true[j] == true && negs_true[j+1] == true) {
				is_eligible = false;
			}
		}
		if(is_eligible == true) {
			eligible_user_count++;
		}
	}

	std::cout << bank._bank_name << "\t" << eligible_user_count << "\t" << bank_balance << std::endl;
	return os;
}