# Macedonian dictionary scraping 

The repository contains R-code and .tcv table. R-code is for data scraping. It forms table-type file macedonian.tcv based on data from [*http://makedonski.info*](http://makedonski.info).
 

## R-code 

The program has two parts. 
In the first part with Macedonian alphabet we form links leading to web-pages for each letter 
[link example http://makedonski.info/letter/к], 
then we extract words' menu and form links for each menu string 
[link example http://makedonski.info/letter/к/крштелен/кубира], from those links we extract lexemes. 
As the result of the firs part we form links for all lexemes, presented in the dictionary 
[link example http://makedonski.info/show/крштење] 

In the second part we proceed to scraping. 
With links from the first part we extract vocabulary information about lexemes from each page.  
As the result we get a table with lines for each dictionary entry with lexeme links in first column and other information in other columns. 
In cases of  polysemantic word, every not-first meaning is separated with separator NEXT_MEANING. 
But the problem comes when there is a lack of a certain tag: all meanings in the cell move up 
