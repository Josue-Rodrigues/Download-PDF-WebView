//
//  ViewController.swift
//  TesteWebView
//
//  Created by Josue Herrera Rodrigues on 13/11/21.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, UIDocumentInteractionControllerDelegate, URLSessionDownloadDelegate {
    
    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//      Inserindo a URL de acesso principal da WEB
        let url = URL(string: "https://www.ciser.com.br/categoria/parafusos")
        webView.load(URLRequest(url: url!))
        webView.allowsBackForwardNavigationGestures = true
    }
    
//  Criando a visualizacao para gerenciamento do controlador
    override func loadView() {
        
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
//  Solicitando permissao ao Delegate para acesso ao icone ou pasta solicitada
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        if let url = navigationAction.request.url {
            
            print("Verificando arquivo baixado ::  \(url)")
//          Recuperando e checando se extensao do arquivo é do tipo PDF
            let extention = "\(url)".suffix(4)
            if extention == ".pdf" {
                
//              Caso o arquivo atenda ao requisitos, devera executar a FUNC DownloadPDF
                DispatchQueue.main.async {
                    self.downloadPDF(tempUrl: "\(url)")
                }
                
//              Bloco para tratamento de conclusão permitindo ou cancelar a navegação (.ALLOW = Permitir / .CANCEL = Cancelar)
                decisionHandler(.cancel)
                return
            }
        }
        
        decisionHandler(.allow)
    }
    
//  Criando a função para Download do arquivo
    func downloadPDF(tempUrl:String) {
        
        guard let url = URL(string: tempUrl) else { return }
        let urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        let downloadTask = urlSession.downloadTask(with: url)
        downloadTask.resume()
    }
    
//  Criando e gerenciando a visualizacao do arquivo na tela
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self
    }
    
//  Informando ao Delegate que o Download foi concluido
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        // Criando um URL de destino com o nome original do PDF
        guard let url = downloadTask.originalRequest?.url else { return }
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        // Esta função executa uma operação do sistema de arquivos para determinar se o componente do caminho é um diretório.
        let destinationURL = documentsPath.appendingPathComponent(url.lastPathComponent)
        // Deletando a copia original
        try? FileManager.default.removeItem(at: destinationURL)
        // Criando um copia temporaria para documentos
        
        do {
            try FileManager.default.copyItem(at: location, to: destinationURL)
            
//          Chamando a funcao de visualizacao da documentacao
            myViewDocumentsmethod(PdfUrl:destinationURL)
            
        } catch let error {
            print("fileDownload: error \(error.localizedDescription)")
        }
    }
    
//  Metodo para visualizacao do documento
    func myViewDocumentsmethod(PdfUrl:URL){
        
        DispatchQueue.main.async {
            
            let controladorDoc = UIDocumentInteractionController(url: PdfUrl)
            controladorDoc.delegate = self
            controladorDoc.presentPreview(animated: true)
        }
    }
}

