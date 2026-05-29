import socket
import threading
import json
import os
import hashlib
import argparse
import time
import random

def calcular_hash(dados):
    return hashlib.sha256(dados).hexdigest()

def preparar_arquivo_teste(nome_arquivo, tamanho_kb, tamanho_bloco):
    tamanho_bytes = tamanho_kb * 1024
    dados = os.urandom(tamanho_bytes)
    with open(nome_arquivo, 'wb') as f:
        f.write(dados)
    
    metadados = {
        "nome_arquivo": nome_arquivo,
        "tamanho_total": tamanho_bytes,
        "tamanho_bloco": tamanho_bloco,
        "hash_original": calcular_hash(dados),
        "blocos_esperados": []
    }
    
    for i in range(0, tamanho_bytes, tamanho_bloco):
        pedaco = dados[i:i+tamanho_bloco]
        metadados["blocos_esperados"].append(calcular_hash(pedaco))
        
    with open("metadata.json", 'w') as f:
        json.dump(metadados, f, indent=4)
        
    print(f"arquivo de teste {nome_arquivo} ({tamanho_kb}KB) gerado com blocos de {tamanho_bloco}b")

class NoP2P:
    def __init__(self, porta, vizinhos, eh_seeder, pasta_destino, tamanho_bloco):
        self.ip = '127.0.0.1'
        self.porta = porta
        self.vizinhos = vizinhos
        self.eh_seeder = eh_seeder
        self.pasta_destino = pasta_destino
        self.tamanho_bloco = tamanho_bloco
        self.meus_blocos = {}
        self.contagem_fontes = {} 
        
        os.makedirs(self.pasta_destino, exist_ok=True)
        
        caminho_log = os.path.join(self.pasta_destino, "log_recebimento.txt")
        self.arquivo_log = open(caminho_log, "w")
        
        with open("metadata.json", 'r') as f:
            self.metadados = json.load(f)
            
        if self.eh_seeder:
            self.carregar_arquivo_completo()

    def carregar_arquivo_completo(self):
        with open(self.metadados["nome_arquivo"], 'rb') as f:
            dados = f.read()
            for i in range(0, len(dados), self.tamanho_bloco):
                pedaco = dados[i:i+self.tamanho_bloco]
                hash_pedaco = calcular_hash(pedaco)
                self.meus_blocos[hash_pedaco] = pedaco

    def iniciar_servidor(self):
        servidor = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        servidor.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        servidor.bind((self.ip, self.porta))
        servidor.listen(10)
        
        while True:
            conexao, endereco = servidor.accept()
            # cria thread pra nao travar o servidor
            thread_cliente = threading.Thread(target=self.atender_pedido, args=(conexao,))
            thread_cliente.start()

    def atender_pedido(self, conexao):
        try:
            pedido = conexao.recv(1024).decode()
            if pedido.startswith("GET"):
                _, hash_pedido = pedido.split(" ")
                if hash_pedido in self.meus_blocos:
                    conexao.sendall(self.meus_blocos[hash_pedido])
                else:
                    conexao.sendall(b"NOT_FOUND")
        except Exception as e:
            pass # ignorar falhas de conexao soltas
        finally:
            conexao.close()

    def pedir_bloco(self, porta_vizinho, hash_bloco):
        cliente = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        try:
            cliente.connect((self.ip, porta_vizinho))
            cliente.sendall(f"GET {hash_bloco}".encode())
            resposta = cliente.recv(self.tamanho_bloco)
            
            if resposta != b"NOT_FOUND":
                if calcular_hash(resposta) == hash_bloco:
                    self.meus_blocos[hash_bloco] = resposta
                    
                    # escreve no log
                    self.arquivo_log.write(f"bloco {hash_bloco[:8]} da porta {porta_vizinho}\n")
                    self.arquivo_log.flush()
                    
                    self.contagem_fontes[porta_vizinho] = self.contagem_fontes.get(porta_vizinho, 0) + 1
                    
                    print(f"peer {self.porta} puxou bloco do vizinho {porta_vizinho}")
                    return True
        except:
            pass
        finally:
            cliente.close()
        return False

    def iniciar_cliente(self):
        if self.eh_seeder:
            return

        blocos_faltando = [b for b in self.metadados["blocos_esperados"] if b not in self.meus_blocos]
        
        while len(blocos_faltando) > 0:
            for hash_bloco in list(blocos_faltando):
                vizinho = random.choice(self.vizinhos)
                if self.pedir_bloco(vizinho, hash_bloco):
                    blocos_faltando.remove(hash_bloco)
            # TODO: ver se esse sleep causa muito delay
            time.sleep(0.05)
            
        self.arquivo_log.close()
        self.montar_arquivo_final()

    def montar_arquivo_final(self):
        # joga pro disco
        caminho_final = os.path.join(self.pasta_destino, f"baixado_{self.metadados['nome_arquivo']}")
        with open(caminho_final, 'wb') as f:
            for hash_bloco in self.metadados["blocos_esperados"]:
                f.write(self.meus_blocos[hash_bloco])
                
        # conferencias
        with open(caminho_final, 'rb') as f:
            hash_final = calcular_hash(f.read())
            
        tam_original = self.metadados['tamanho_total']
        tam_final = os.path.getsize(caminho_final)
        
        caminho_relatorio = os.path.join(self.pasta_destino, "RELATORIO_FINAL.txt")
        with open(caminho_relatorio, "w") as f:
            f.write(f"--- Relatorio do Peer {self.porta} ---\n\n")
            
            f.write("Verificacao de Tamanho:\n")
            f.write(f"Original: {tam_original}\n")
            f.write(f"Recebido: {tam_final}\n")
            f.write("Status: OK\n\n" if tam_original == tam_final else "Status: ERRO\n\n")
            
            f.write("Verificacao de Integridade (Hash):\n")
            f.write(f"Original: {self.metadados['hash_original']}\n")
            f.write(f"Recebido: {hash_final}\n")
            f.write("Status: OK\n\n" if hash_final == self.metadados['hash_original'] else "Status: ERRO\n\n")
            
            f.write("Resumo de Fontes (Downloads):\n")
            for porta, qtd in self.contagem_fontes.items():
                f.write(f"Porta {porta}: {qtd} blocos\n")        

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--porta', type=int)
    parser.add_argument('--vizinhos', type=int, nargs='+', default=[])
    parser.add_argument('--seeder', action='store_true')
    parser.add_argument('--preparar', type=int) 
    parser.add_argument('--bloco', type=int, default=1024)
    args = parser.parse_args()

    if args.preparar:
        preparar_arquivo_teste("teste.bin", args.preparar, args.bloco)
        exit()

    pasta = f"dados_peer_{args.porta}"
    no_p2p = NoP2P(args.porta, args.vizinhos, args.seeder, pasta, args.bloco)
    
    thread_servidor = threading.Thread(target=no_p2p.iniciar_servidor, daemon=True)
    thread_servidor.start()
    
    no_p2p.iniciar_cliente()
    
    while True:
        time.sleep(1)