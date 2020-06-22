#include "Account.h"
#include <time.h>
#include <stdio.h>
#include <stdint.h>
#include <ctime>
#include <array>
#include <stdlib.h>

Account::Account() {
	this->_id = -1;
	this->_activity = new Transaction*[12];
	for(int i = 0; i < 12; i++) {
		this->_activity[i] = nullptr;
	}
	this->_monthly_activity_frequency = nullptr;
}

// ASK SOMEBODY //
Account::~Account() {
}

Account::Account(const Account& rhs) {
	this->_id = rhs._id;
	this->_activity = new Transaction*[12];
	this->_monthly_activity_frequency = new int [12];
	for(int i = 0; i < 12; i++) {
		this->_monthly_activity_frequency[i] = rhs._monthly_activity_frequency[i];
		this->_activity[i] = new Transaction [this->_monthly_activity_frequency[i]];
		for(int j = 0; j < this->_monthly_activity_frequency[i]; j++) {
			this->_activity[i][j] = rhs._activity[i][j];
		}
	}
	this->_activity = rhs._activity;
	this->_monthly_activity_frequency = rhs._monthly_activity_frequency;
}

Account::Account(int id, Transaction** const activity, int* monthly_activity_frequency) {
	this->_id = id;
	this->_monthly_activity_frequency = new int [12];
	this->_activity = new Transaction*[12];
	for(int i = 0; i < 12; i++) {
		this->_monthly_activity_frequency[i] = monthly_activity_frequency[i];
		this->_activity[i] = new Transaction [this->_monthly_activity_frequency[i]];
		for(int j = 0; j < this->_monthly_activity_frequency[i]; j++) {
			this->_activity[i][j] = activity[i][j];
		}
	}
}

Account::Account(const Account& rhs, time_t start_date, time_t end_date) {
	this->_id = rhs._id;
	this->_monthly_activity_frequency = new int [12];
	this->_activity = new Transaction*[12];
	int k[12];

	for(int i = 0; i < 12; i++) {
		k[i] = 0;
		for(int j = 0; j < rhs._monthly_activity_frequency[i]; j++) {
			if (rhs._activity[i][j]>start_date && rhs._activity[i][j]<end_date) {
				k[i]++;
			}
		}
	}

	for(int i = 0; i < 12; i++) {
		this->_monthly_activity_frequency[i] = k[i];
		this->_activity[i] = new Transaction [this->_monthly_activity_frequency[i]];
	}
	
	for(int i = 0; i < 12; i++) {
		k[i] = 0;
		for(int j = 0; j < rhs._monthly_activity_frequency[i]; j++) {
			if (rhs._activity[i][j]>start_date && rhs._activity[i][j]<end_date) {
				this->_activity[i][k[i]] = rhs._activity[i][j];
				k[i]++;
			}
		}
	}
}

Account::Account(Account&& rhs) {
	this->_monthly_activity_frequency = new int [12];
	this->_activity = new Transaction*[12];
	this->_id = rhs._id;
	if(this != &rhs) {
		rhs._id = -1;
		for(int i = 0; i < 12; i++) {
			this->_activity[i] = rhs._activity[i];
			rhs._activity[i] = nullptr;
		}
		rhs._activity = nullptr;
		this->_monthly_activity_frequency = rhs._monthly_activity_frequency;
		rhs._monthly_activity_frequency = nullptr;
	}
}

Account& Account::operator=(Account&& rhs) {
	if(this != &rhs) {
		this->_id = rhs._id;
		rhs._id = -1;
		for(int i = 0; i < 12; i++) {
			this->_activity[i] = rhs._activity[i];
			rhs._activity[i] = nullptr;
		}
		rhs._activity = nullptr;
		this->_monthly_activity_frequency = rhs._monthly_activity_frequency;
		rhs._monthly_activity_frequency = nullptr;
	}
	return *this;
}

Account& Account::operator=(const Account& rhs) {
	this->_id = rhs._id;
	this->_monthly_activity_frequency = new int [12];
	this->_activity = new Transaction*[12];
	for(int i = 0; i < 12; i++) {
		this->_monthly_activity_frequency[i] = rhs._monthly_activity_frequency[i];
		this->_activity[i] = new Transaction [this->_monthly_activity_frequency[i]];
		for(int j = 0; j < this->_monthly_activity_frequency[i]; j++) {
			this->_activity[i][j] = rhs._activity[i][j];
		}
	}
	return *this;
}

bool Account::operator==(const Account& rhs) const {
	if(rhs._id == this->_id) {
		return true;
	}
	return false;
}

bool Account::operator==(int id) const {
	std::cout << "bel2: " << this->_id << std::endl;
	if(id == this->_id) {
		std::cout << "== true " << std::endl;
		return true;
	}
	return false;
}

Account& Account::operator+=(const Account& rhs) {
	
	for(int i = 0; i < 12; i++) {
		int old = this->_monthly_activity_frequency[i];
		Transaction* old_arr = this->_activity[i];

		this->_monthly_activity_frequency[i] += rhs._monthly_activity_frequency[i];
		this->_activity[i] = new Transaction [this->_monthly_activity_frequency[i]];
		for(int j = 0; j < old; j++) {
			this->_activity[i][j] = old_arr[j];
		}
		for(int j = 0; j < rhs._monthly_activity_frequency[i]; j++) {
			this->_activity[i][j+old] = rhs._activity[i][j];
		}
	}

	return *this;
}

double Account::balance() {
	int sum = 0;

	for(int i = 0; i < 12; i++) {
		for(int j = 0; j < this->_monthly_activity_frequency[i]; j++) {
			sum = this->_activity[i][j]+sum;
		}
	}

	return sum;
}

double Account::balance(time_t end_date) {
	int sum = 0;
	if(this->_monthly_activity_frequency != nullptr) {
			for(int i = 0; i < 12; i++) {
				for(int j = 0; j < this->_monthly_activity_frequency[i]; j++) {
					if (this->_activity[i][j]<end_date) {
						sum = this->_activity[i][j]+sum;
					}
				}
			}
		}

	return sum;
}

double Account::balance(time_t start_date, time_t end_date) {
	int sum = 0;

	if(this->_monthly_activity_frequency != nullptr) {
		for(int i = 0; i < 12; i++) {
			for(int j = 0; j < this->_monthly_activity_frequency[i]; j++) {
				if (this->_activity[i][j]>start_date && this->_activity[i][j]<end_date) {
					sum = this->_activity[i][j]+sum;
				}
			}
		}
	}
	return sum;
}

void swap(Transaction* a, Transaction* b)  
{  
	Transaction t = *a;  
    *a = *b;  
    *b = t; 
}  

int divide(Transaction arr[], int a, int b) {
	Transaction pivot = arr[b]; 
    int k = (a - 1);
    for (int i = a; i <= b - 1; i++)  
    {   
        if (arr[i] < pivot)  
        {  
            k++; 
            swap(&arr[k], &arr[i]);  
        }  
    }
    swap(&arr[k + 1], &arr[b]);
    return (k + 1); 
}

void sort(Transaction arr[], int a, int b) {
	if(b >= a) {
		int c = divide(arr, a, b);
		sort(arr, a, c-1);
		sort(arr, c+1, b);
	}
}

std::ostream& operator<<(std::ostream& os, const Account& account) {
	std::cout << account._id << std::endl;
	if(account._activity != nullptr) {
		for(int i = 0; i < 12; i++) {
			sort(account._activity[i], 0, account._monthly_activity_frequency[i]-1);
			for(int j = 0; j < account._monthly_activity_frequency[i]; j++) {
				std::cout << account._activity[i][j];
			}
		}
	}
	return os;
}