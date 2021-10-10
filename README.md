# Macedonian dictionary scraping 

The repository contains R-code and .tcv table. R-code is for data scraping. It forms table-type file macedonian.tcv based on data from [*http://makedonski.info*](http://makedonski.info).
 

## R-code 

The program has two parts. 

In the first part we form links to web-pages for each letter 
`link example: <http://makedonski.info/letter/к>`,  
then we extract words' menu and form links for each menu string 
`link example: <http://makedonski.info/letter/к/крштелен/кубира>`, from those links we extract lexemes.  
As the result of the firs part we form links for all lexemes, presented in the dictionary 
`link example: <http://makedonski.info/show/крштење>` 

In the second part we proceed to scraping. 
With links from the first part we extract vocabulary information about lexemes from each page.  
As the result we get a table with lines for each dictionary entry with lexeme links in first column and other information in other columns. 
In cases of  polysemantic word, every not-first meaning is separated with separator NEXT_MEANING. 
But the problem comes when there is a lack of a certain tag: all meanings in the cell move up 

## .tcv table 

The dictionary is a table where each line is a dictionary entry and each column is articles' content. 
It has 54475 lines: first line for columns names, (=54474 dictionary entries) and 11 columns.

* in the first column there are links to the dictionary articles, 
* second column contains example of inflected form (tag *flexion*), 
* in the third — grammatical information (tag *grammar*), 
* in the fourth — definition(s) (tag *definition*), 
* in the fifth — translations to foreign languages (English, Turkish, Albanian and some others) (tag *translation*), 
* in the sixth — commentaries about usage (tag *used*), 
* in the seventh — example of usage (tag *example*), 
* in the eighth — connected links (tag *semem_links*), 
* in the ninth — examples of idioms and its usage (tag *idiom*), 
* in the tenth — the word's derivates (tag *derivation*), 
* in the eleventh — word (lexeme) 

## Authors

* **George Moroz** 
* **Ksenia Romanova** 

See also the list of [contributors](https://github.com/xenicR/macedonian-dictionary/graphs/contributors).
