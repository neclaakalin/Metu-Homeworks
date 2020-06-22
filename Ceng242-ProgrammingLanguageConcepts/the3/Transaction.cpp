#include "Transaction.h"
#include <time.h>
#include <stdio.h>
#include <stdint.h>
#include <ctime>

Transaction::Transaction() {
	this->_amount = -1;
	this->_date = -1;
}

Transaction::Transaction(double amount, time_t date) {
	this->_amount = amount;
	this->_date = date;
}

Transaction::Transaction(const Transaction& rhs) {
	this->_amount = rhs._amount;
	this->_date = rhs._date;
}

bool Transaction::operator<(const Transaction& rhs) const {
	if(this->_date < rhs._date) {
		return true;
	}
	return false;
}

bool Transaction::operator>(const Transaction& rhs) const {
	if(this->_date > rhs._date) {
		return true;
	}
	return false;
}

bool Transaction::operator<(const time_t date) const {
	if(date > this->_date) {
		return true;
	}
	return false;
}

bool Transaction::operator>(const time_t date) const {
	if(date < this->_date) {
		return true;
	}
	return false;
}

double Transaction::operator+(const Transaction& rhs) {
	return rhs._amount + this->_amount;
}

double Transaction::operator+(const double add) {
	return this->_amount + add;
}

Transaction& Transaction::operator=(const Transaction& rhs) {
	this->_amount = rhs._amount;
	this->_date = rhs._date;
	return *(this);
}

std::ostream& operator<<(std::ostream& os, const Transaction& transaction) {
	tm *t = localtime(&transaction._date);
	std::cout << transaction._amount << "\t-\t" << t->tm_hour << ":" << t->tm_min << ":" << t->tm_sec << "-" << t->tm_mday << "/" << t->tm_mon+1 << "/" << t->tm_year+1900 << std::endl;
	return os;
}
