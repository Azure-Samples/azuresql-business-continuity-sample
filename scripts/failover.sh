# Params:
#     - FOG Name
#     - SQL Server Resource Group Name (Secondary if Failover, Primary if Failback)
#     - SQL Server Name (Secondary if Failover, Primary if Failback)
function failover_sqlazure_server() {
  fog_name=$1
  sql_rg=$2
  sql_server_name=$3
  az sql failover-group show --name $fog_name --resource-group $sql_rg --server $sql_server_name --query replicationRole > replicationRole
  status=$(cat replicationRole);
  if [ $status == "\"Secondary\"" ]; then
    echo "Current role of Azure SQL is Secondary.. Initiate failover.."
    az sql failover-group set-primary --name $fog_name --resource-group $sql_rg --server $sql_server_name --only-show-errors;
  else
    echo "Cannot initiate Azure SQL Failover (or Azure SQL fail over is complete)";
    echo "INFO: Azure SQL Details:";
    az sql failover-group show --name $fog_name --resource-group $sql_rg --server $sql_server_name
  fi
}

echo "Failover SQL Azure"
failover_sqlazure_server $1 $2 $3