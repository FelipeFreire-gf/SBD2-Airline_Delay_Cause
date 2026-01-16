# Bem-vindo ao Projeto Análise de Atrasos de Voos

Esta é a documentação oficial do projeto. Aqui você encontrará os requisitos, diagramas e guias de desenvolvimento para o sistema de análise de atrasos de voos em aeroportos dos Estados Unidos.

## Estrutura do Projeto

* **Requisitos Funcionais**: Detalhamento dos casos de uso e funcionalidades do sistema de análise.
* **Modelagem de Dados**: Diagramas ER e relacionais para o banco de dados de atrasos de voos.
* **Pipeline ETL**: Arquitetura Medallion (Bronze, Silver, Gold) para processamento de dados.
* **Análises**: Visualizações e insights sobre atrasos, causas, tendências e sazonalidade.
* **Guias**: Padrões de projeto e contribuição.

## Sobre os Dados

O projeto analisa dados históricos de atrasos de voos em aeroportos americanos, incluindo:
- Informações temporais (ano, mês)
- Companhias aéreas e aeroportos
- Métricas de voos (chegadas, atrasos ≥15min, cancelamentos, desvios)
- Causas de atrasos (companhia aérea, meteorologia, NAS, segurança, aeronave atrasada)
- Tempos de atraso por categoria

Para começar a contribuir, leia o [Guia de Contribuição](CONTRIBUTING.md).
