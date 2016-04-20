---
layout: post
title: "Javascript Challenges 1.1: Self Invoking Functions"
categories: ["js-challenges"]
---

這篇短文是練習 [Javascript Challenges](https://github.com/tcorral/javascript-challenges-book) 第 1-1 小節時所做的筆記。

## 題目
我想要利用 `Self Invoking Function` 把 `testValue` 的值設成 `3`，你可以幫我這個忙嗎？

```js
var testValue;
function test() {
	testValue = 3;
}();
```

1. 如果我試著執行上面的程式碼，會得到什麼結果呢？
2. `testValue` 的值會是什麼呢？
3. 承上題，為什麼 `testValue` 的值會是這個？
4. 幫上面的這段程式碼加上 **一個字元** 讓它可以正常執行。



## 概念

### Function

在 Javascript 裡，如果要定義一個函式 (function) ，我們可以用這樣的語法：

```js
function sayHello() {
	console.log('你好！');
}
```

或是使用匿名函式 (anonymous function) 的方法宣告：

```js
var sayHello = function(){
	console.log('Hello everyone');
};
```

如果我們要呼叫這個函式可以：

```js
sayHello();
```

### Self Invoking Function

如果我們想要讓一個函式可以自己執行而不需要我們去呼叫的話，我們可以利用 self invoking function 的方式來寫。

#### Basics

第一種寫法

1. 在函式的外面加一對小括號
2. 並且在最尾巴加一對小括號，讓前面的函式自動執行。

範例：

```js
(function(){
	console.log('你好！');
})();
```

另一種寫法

1. 在 `function` 的前面加上一個 `!`
2. 當然，別忘了在最尾巴加上一對小括號。

範例：

```js
!function(){
	console.log('你好！');
}();
```

加上 `!` 的主要是因為如果用 `function` 開頭的話，直譯器 (interpreter) 會認為我們在宣告函式。

但是我們現在所寫的是一行會被執行的指令，根據 [ECMA 的規範](http://www.ecma-international.org/ecma-262/5.1/#sec-12.4)：

> Also, an `ExpressionStatement` cannot start with the `function` keyword because that might make it ambiguous with a `FunctionDeclaration`.

所以我們必須利用 `!` 告訴直譯器：接下來的這些是一條指令，而不是在宣告函式。

因為 self invoking function 本身就是個函式，所以當然可以有參數，有興趣的話可以自己試試看。

這邊提供一個範例：

```js
!function(name){
	console.log('你好，' + name + '！');
}('柯P');
```

#### Named Self Invoking Function

上面所提到的都是匿名的 self invoking function。

當然，我們也可以宣告一個有名字的 self invoking function：

範例：

```js
(function sayHello(){
	console.log('你好！');
})();
```

不過，我們無法在外頭呼叫這個函式，如果你嘗試呼叫的話：

```js
sayHello();
```

就會得到像是這樣的訊息：

```js
ReferenceError: sayHello is not defined
```

你可能會有一個疑問，既然我們在外頭無法呼叫這個函式，為什麼要給它名字呢？

如果你想到這個問題，就代表你突破盲點了！

沒錯，我們不能在函式 *外面* 呼叫，但是我們可以在函式 *裡面* 呼叫！

例如我們想寫一個算 [費氏數列](http://zh.wikipedia.org/zh-tw/%E6%96%90%E6%B3%A2%E9%82%A3%E5%A5%91%E6%95%B0%E5%88%97) 的函式，可以利用遞迴的方式來寫：

```js
(function fibonacci(seq){
	if(seq <= 2)
		return 1;
	else
		return fibonacci(seq-1) + fibonacci(seq-2);
})(10);
```

因為利用遞迴的方式，所以會需要持續的呼叫 `fibonacci`，如此我們需要給這個函式一個名字。

## 解答

根據上面所提到的觀念，我們就來看看這題的解答吧！

```js
var testValue;
function test() {
	testValue = 3;
}();
```

Q: 如果我試著執行上面的程式碼，會得到什麼結果呢？

> `SyntaxError: Unexpected token )`
>
> 原因：宣告 self invoking function 的語法不正確。

Q: `testValue` 的值會是什麼呢？

Q: 承上題，為什麼 `testValue` 的值會是這個？

> `undefined`
>
> 因為 self invoking function 沒有被執行，所以 `testValue` 的值，會是預設的 `undefined`。


Q: 幫上面的這段程式碼加上 **一個字元** 讓它可以正常執行。

> 在 function 前面加上一個 `!` 即可。


```js
var testValue;
!function test() {
  testValue = 3;
}();
```

## 參考資料

- Sarfraz Ahmed - Javascript Self Invoking Functions:

	<http://sarfraznawaz.wordpress.com/2012/01/26/javascript-self-invoking-functions/>

- ECMAScript Language Specification:

	<http://www.ecma-international.org/ecma-262/5.1/>

- Named Self Invoking Function:

	<http://stackoverflow.com/questions/10947248/named-self-invoking-function>
