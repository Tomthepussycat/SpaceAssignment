import os
import csv
import json 
import datetime

# Simply read csv
with open('data.csv', mode='r') as file:
    csv_reader = csv.reader(file)
    data = list(csv_reader)

class Contract_record :

    def __init__(self, record):
        self.id = record[0]
        self.date = record[1]
        # Raw contracts
        self.contracts_raw = self.get_json(record[2])
        # Unpacked contracts -> list of dictionaries
        self.contracts = self.unpack_contracts(self.contracts_raw,[])

    # To read json
    def get_json(self,data):
        try: 
            return json.loads(data)
        except json.JSONDecodeError as e:
            return None


    # Since contracts row contains nested list of dictionaries, We need to "flatten" these lists.
    # This function will recursively unpack lists of any complexity and build one list consisting of dictionaries. 
    def unpack_contracts(self, target,dictionaries):
        if target is None:
            return dictionaries
        for i in target:
            if(type(i) is dict):
                dictionaries.append(i)
            elif(type(i) is list):
                self.unpack_contracts(i,dictionaries)
        return dictionaries 

    # Returns quantity of claims in last period of time ( date param in days )
    def get_latest_claims(self,days):

        
        result = list(filter(lambda x : (x['claim_date'] is not None) & (x['claim_id'] is not None) &
                             (datetime.datetime.strptime(( x['claim_date']),"%d.%m.%Y") >= datetime.datetime.now() - datetime.timedelta(days))
                             ,self.contracts))
        return len(result)

    def get_disbursed_loans(self,exc_list):
        #result = list(filter(lambda x : ('bank' in x) & (x['bank'] not in(exc_list)) & (x['bank'] is not None) & (x['contract_date'] is not None),self.contracts))
        result = list(filter(
            lambda x: (
                'bank' in x and  
                x['bank'] not in exc_list and  
                x['bank'] != '' and
                x['bank'] is not None and  
                x['contract_date'] is not None 
            ),
            self.contracts
        ))
        
        return result

    def get_last_loan_date(self):
        l = list(filter(
            lambda x: ('summa' in x and
                x['summa'] is not None and
                x['summa'] != '' and 
                x['summa'] != '0'
            )
            ,self.contracts 
        ))

        data = [datetime.datetime.strptime(x['contract_date'],"%d.%m.%Y") for x in l]
        if len(data)==0:
            return None
        
        return max(data)

# Returns all Contracts
def GetContracts():
    result = []
    for rec in data[1:]:
        result.append(Contract_record(rec))
    
    return result

# Takes:
#  * applications _> All the applications we want to process
#  * fileName _> File we want to Create and write or append to 
#  * days _> Period, for which to count claims. since there were no claims in the last 180 days, 
#                       we can specify larger period of time so that we can get different results 
def WriteTotalClaims(applications,fileName,days):
    with open(fileName, mode='a',newline='') as file:
        writer = csv.writer(file) 
        if (not(os.path.exists(fileName)) or os.stat(fileName).st_size == 0):
            writer.writerow(['id','application_date','tot_claim_cnt_l180d'])
        for record in applications:
            if (len(record.contracts)>0):
                claim_quantity = record.get_latest_claims(days)
            else:
                claim_quantity = -3
            writer.writerow([record.id,record.date,claim_quantity])


def Write_disbursed_loans(fileName,exclude_from_list):
    with open(fileName, mode='a',newline='') as file:
        writer = csv.writer(file) 
        if (not(os.path.exists(fileName)) or os.stat(fileName).st_size == 0):
            writer.writerow(['id','application_date','bank','loan_summa','contract_date'])
        for record in GetContracts():
            if (len(record.contracts) == 0 ):
                writer.writerow([record.id,record.date,-3,'',''])
                continue
            for r in record.get_disbursed_loans(exclude_from_list):
                if (type(r['contract_date']) == ''):
                    writer.writerow[record.id,record.date,r['bank'],-1,'']
                    continue
                writer.writerow([record.id,record.date,r['bank'],r['loan_summa'],r['contract_date']])


def WriteDaysSinceLastLoan(fileName):
    with open(fileName, mode='a',newline='') as file:
        writer = csv.writer(file) 
        if (not(os.path.exists(fileName)) or os.stat(fileName).st_size == 0):
            writer.writerow(['id','application_date','last_loan_date','Days_since_last_loan'])
        for record in GetContracts():
            if(len(record.contracts)==0):
                writer.writerow([record.id,record.date,-3])
            v = record.get_last_loan_date()
            if(v is None):
                writer.writerow([record.id,record.date,-1])
            else: 
                writer.writerow([record.id,record.date,record.date,datetime.datetime.now() - v])

# #
# # Calculate claims for last 180 and 500 days ( Task 1 )
# WriteTotalClaims(GetContracts(),'180_days_data.csv',180) # Calculate for 180 days
# WriteTotalClaims(GetContracts(),'500_days_data.csv',500) # Calculate for 500 days

# # Get records of disposed loans ( Task 2 )
# Write_disbursed_loans('loans_test.csv',['LIZ','LOM','MKO','SUG']) # Exclude these banks ['LIZ','LOM','MKO','SUG'] 
# Write_disbursed_loans('loans_test3.csv',['63']) # Exclude these banks ['63'] 

WriteDaysSinceLastLoan('TestDaysScince.csv')