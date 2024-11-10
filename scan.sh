#!/bin/bash

# Excluir diretório nmap-vulners se já existir
rm -rf nmap-vulners

# Baixar nmap-vulners atualizado
git clone https://github.com/vulnersCom/nmap-vulners.git

# Solicitar ao usuário o intervalo de IPs
read -p "Digite o IP base (exemplo: 10.1.0.): " base_ip
read -p "Digite o número inicial do último octeto do IP: " start_ip
read -p "Digite o número final do último octeto do IP: " end_ip

# Diretório para salvar os relatórios
report_dir="/home/manuel/Documents/report"
if [ ! -d "$report_dir" ]; then
  echo "Diretório de relatório $report_dir não existe. Criando..."
  mkdir -p "$report_dir"
fi

# Arquivo para o relatório final resumido
summary_report="${report_dir}/summary_report.txt"

# Inicializa o arquivo de relatório
echo "Resumo de Portas Abertas e CVEs por Host" > "$summary_report"
echo "---------------------------------------" >> "$summary_report"

# Loop através da faixa de IPs
for i in $(seq "$start_ip" "$end_ip")
do
  # Define o IP atual
  current_ip="${base_ip}${i}"
  
  # Executa o comando nmap e salva a saída
  echo "Iniciando scan para o IP: $current_ip"
  nmap_output=$(mktemp)
  nmap -sV --script nmap-vulners/ --open -Pn -oN "$nmap_output" "$current_ip"
  
  # Verifica se o comando nmap foi executado com sucesso
  if [ $? -eq 0 ]; then
    echo "Scan concluído para o IP: $current_ip."
    
    # Extrai informações relevantes e adiciona ao relatório
    echo "Host: $current_ip" >> "$summary_report"
    grep -E "open|cve" "$nmap_output" >> "$summary_report"
    
    # Verifica e adiciona as linhas relacionadas a exploits, se existirem
    grep -i "exploit" "$nmap_output" >> "$summary_report"
    
    echo "" >> "$summary_report"
  else
    echo "Erro ao executar o scan para o IP: $current_ip"
  fi
  
  # Remove o arquivo temporário
  rm "$nmap_output"
done

echo "Relatório salvo em: $summary_report"
