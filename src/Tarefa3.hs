{- |
Module : Tarefa 3
Description: Funções da Tarefa 3
Copyright: Rui Nuno Vilaça Ribeiro, Nelson Tiago 

Este é um módulo contém Funções inerentes à tarefa 3 com o objetivo de comprimir e descomprimir o mapa para que se torne mais leve
-}
module Main where
import System.Environment
import Data.Char
import Data.List

{- | Faz o unlines do mapa comprimido e das coordenadas

=Exemplos

>>>encode ["#######","#  ?  #","# # # #","#     #","# #?# #","#  ?  #","#######","+ 3 1","! 3 4"]
"#7\n?\n# #\n 5\n#?#\n?\n#7\nc+ 3 1\n! 3 4\n"
-}

encode :: 
 [String] -- ^ Lista com as Strings do mapa e as coordenadas dos power ups 
 -> String -- ^ String que resulta da nossa compressão do mapa 
encode (h:t) = unlines (comprime (take (length h) (h:t)))++ "c" ++unlines (drop (length h) (h:t))

{- | Faz a compressão apenas do mapa

=Exemplos

>>>comprime ["#######","#  ?  #","# # # #","#     #","# #?# #","#  ?  #","#######"]
["#7","?","# #"," 5","#?#","?","#7"]
-}

comprime :: 
 [String] -- ^ Lista com as Strings do mapa 
 -> [String] -- ^ Lista com as Strings do mapa comprimidas
comprime t = aux t 1 tl
        where aux t l tl | t == [] = []
                         | l == 1 || l==tl = [] :aux (drop 1 t) (l+1) tl 
                         | l == 2 || l==(tl-1) =  comprimeL2 (head t) :aux (drop 1 t) (l+1) tl
                         | l == 3 || l==(tl-2) =  comprimeEven("#" ++ comprimeL3 (head t) ++ "#") :aux (drop 1 t) (l+1) tl
                         | (l >= 4 || l<=(tl-3)) && odd l =comprimeEven ("#" ++ comprimeOdd (head t) ++ "#"):aux (drop 1 t) (l+1) tl 
                         | (l >= 4 || l<=(tl-3)) && even l = comprimeEven (head t) :aux (drop 1 t) (l+1) tl
                         | otherwise = []

              tl = length t

{- | Faz a compressão da 2º linha do mapa

=Exemplos
>>>comprimeL2 "#     #"
" "
-}

comprimeL2 ::
 String -- ^ 2º linha do mapa 
 -> String -- ^ 2º linha do mapa comprimida
comprimeL2 l = repetidos (take ((length l)-6) (drop 3 l))

{- | Faz a compressão da 3º linha do mapa

=Exemplos
>>>comprimeL3 "# # # #"
"# #"
-}

comprimeL3 :: 
 String -- ^ 3º linha do mapa 
 -> String -- ^ 3º linha do mapa comprimida
comprimeL3 l = comprimeOdd (take ((length l)-4) (drop 2 l))

{- | Faz a compressão das linhas pares do mapa (excepto 1º,2º,3º, última, penúltima e antepenúltima)

=Exemplos
>>>comprimeEven "#     #"
" 5"
-}

comprimeEven :: 
 String -- ^ linha par do mapa
 -> String -- ^ linha par do mapa comprimida
comprimeEven l = repetidos (take ((length l)-2) (drop 1 l))

{- | Faz a compressão das linhas ímpares do mapa (excepto 1º,2º,3º, última, penúltima e antepenúltima)

=Exemplos
>>>comprimeOdd "# # #?#?#"
"  ??"
-} 

comprimeOdd :: 
 String -- ^ linha ímpar do mapa 
 -> String -- ^ linha ímpar comprimida do mapa
comprimeOdd (h:t) = filter (\h-> h/='#') (h:t)

{- | Retira, de um mapa comprimido, os elementos que se repetem seguidamente (o elemento segue-se do numéro de vezes que se repete)

=Exemplos
>>>repetidos "  ??"
" 2?2"
-} 

repetidos :: 
 String -- ^ linha comprimida 
 -> String -- ^ linha comprimida sel elementos repetidos
repetidos [] = []
repetidos (h:t) | length (head (group (h:t)))>1 = show (length (head (group (h:t)))) ++ [h] ++ repetidos (drop (length (head (group (h:t)))) (h:t))
                | otherwise = [h]  ++ repetidos t

{- | Faz a descompressão do lines do mapa (numa String) comprimido adicionando as coordenadas dos Power ups

=Exemplos
>>>decode "#7\n?\n# #\n 5\n#?#\n?\n#7\nc+ 3 1\n! 3 4\n"
["#######","#  ?  #","# # # #","#     #","# #?# #","#  ?  #","#######","+ 3 1","! 3 4"]
-} 

decode :: 
 String -- ^ mapa com as coordenadas comprimida
 -> [String] -- ^ mapa com as coordenadas dos power ups
decode l = (descomprime (lines (fst(partecomp l))) ++ lines (snd(partecomp l)))



{- | Faz a descompressão de parte do mapa comprimido

=Exemplos
>>>descomprime "#7\n?\n# #\n 5\n#?#\n?\n#7\nc+ 3 1\n! 3 4\n"
["#######","#  ?  #","# # # #","#     #","# #?# #","#  ?  #","#######","+ 3 1","! 3 4"]
-} 

descomprime :: 
 [String] -- ^ mapa comprimido e sem os extremos pré-definidos 
 -> [String] -- ^ mapa comprimido com os extremos pré-definidos adicionados
descomprime t = aux t 1 tl
        where aux t l tl | t == [] = []
                         | l == 1 || l==tl = replicate tl '#' :aux (drop 1 t) (l+1) tl 
                         | (l == 2 || l==(tl-1)) && tl >5 = ("#  "++(descomprimeEven2 (head t))++"  #"):aux (drop 1 t) (l+1) tl
                         | l == 2 || l==(tl-1) = "#   #":aux (drop 1 t) (l+1) tl
                         | l == 3 || l==(tl-2) = ("# "++descomprimeOdd3(descomprimeEven2 (head t))++" #"):aux (drop 1 t) (l+1) tl
                         | (l >= 4 || l<=(tl-3)) && odd l = descomprimeOdd3(descomprimeEven2 (head t)):aux (drop 1 t) (l+1) tl 
                         | (l >= 4 || l<=(tl-3)) && even l = ("#"++descomprimeEven2 (head t)++"#"):aux (drop 1 t) (l+1) tl
                         | l > tl = []
              tl = length t

{- | Faz a descompressão da 1º linha comprimida

=Exemplos
>>>descomprimeL1 "#7"
"#######"
-} 

descomprimeL1 :: 
 String -- ^ 1º linha comprimida 
 -> String -- ^ 1º linha descomprimida 
descomprimeL1 (h:n) = replicate (read n) h 

{- | Faz a descompressão das linhas ímpares comprimidas

=Exemplos
>>>descomprimeOdd3 " ? "
"# #?# #"
-} 

descomprimeOdd3 :: 
 String -- ^ linha ímpar comprimida 
 -> String -- ^ linha ímpar descomprimida
descomprimeOdd3 [] = "#"
descomprimeOdd3 [h] = '#':[h]++descomprimeOdd3 []
descomprimeOdd3 (h:t) = '#':[h]++descomprimeOdd3 t

{- | Faz a descompressão das linhas pares comprimidas

=Exemplos
>>>descomprimeEven2 "? 4? "
"?    ? "
-} 

descomprimeEven2 :: 
 String -- ^ linhas pares ou linha 3 comprimida
 -> String -- ^ linhas pares ou linha 3 descomprimida
descomprimeEven2 [] = []
descomprimeEven2 [x] = [x]
descomprimeEven2 (x:xs) = aux (x:xs) []
   where aux [] []  = []
         aux [] [a] = [a]
         aux [] d = desdedobra d
         aux (x:xs) d | x=='?' || x==' ' = desdedobra (x:d) ++ descomprimeEven2 xs 
                      | otherwise = aux xs (d ++ [x])

{- | Pega nos numeros do mapa comprimido e repete o numero de vezes do elemento antecedente 

=Exemplos
>>>desdobra " 3"
"   "
-} 

desdedobra :: 
   String -- ^ caracteres que vai desdobrar 
      -> String -- ^caracteres desdobrados
desdedobra [] = []
desdedobra [h] = [h]
desdedobra [h,t] | not(isDigit t) = [h,t]
                 | otherwise = replicate (digitToInt t) h
desdedobra (h:t) = replicate (read t :: Int) h

{- | Divide o mapa das coordenadas dos power ups

=Exemplos
>>>partecomp ""#7\n?\n# #\n 5\n#?#\n?\n#7\nc+ 3 1\n! 3 4\n""
"("#7\n?\n# #\n 5\n#?#\n?\n#7\n","+ 3 1\n! 3 4\n")"
-} 

partecomp :: 
 String -- ^ mapa e coordenadas comprimidas 
 -> (String,String) -- ^ par com o mapa comprimido na 1º coordenada e as coordenadas dos power ups na 2º coordenadas
partecomp [] = ([],[])
partecomp (h:t) = (a,b)
            where a = parteaux1 (h:t)
                  b = parteaux2 (h:t)

{- | Retira o mapa comprimido

=Exemplos
>>>parteaux1 "#7\n?\n# #\n 5\n#?#\n?\n#7\nc+ 3 1\n! 3 4\n"
"#7\n?\n# #\n 5\n#?#\n?\n#7\n"
-}                 

parteaux1 :: 
 String -- ^ mapa comprimido com as coordenadas do power ups
 -> String -- ^ mapa comprimido
parteaux1  [] = []
parteaux1 (h:t) = aux (h:t) []
    where   aux [] new = new
            aux (h:t) new | h /= 'c' = new ++ [h] ++ aux t new
                          | h ==  'c' = new

{- | Retira ãs coordenadas comprimidas

=Exemplos
>>>parteaux2 "#7\n?\n# #\n 5\n#?#\n?\n#7\nc+ 3 1\n! 3 4\n"
"+ 3 1\n! 3 4\n"
-}                 

parteaux2 :: 
 String -- ^ mapa comprimido com as coordenadas do power ups
 -> String -- ^ coordenadas dos power ups comprimidas
parteaux2  [] = []
parteaux2 (h:t) = aux (h:t) []
    where   aux [] new = new
            aux (h:t) new | h /= 'c' = aux t new
                          | h ==  'c' = t 

main :: IO ()
main = do a <- getArgs
          let p = a !! 0
          w <- getContents
          if length a == 1 && length p == 2 && (p=="-e" || p=="-d")
             then if p=="-e" then putStr $ encode $ lines w
                             else putStr $ unlines $ decode w
             else putStrLn "Parâmetros inválidos"