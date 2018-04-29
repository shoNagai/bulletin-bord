pragma solidity ^0.4.18;

import "./Mortal.sol";
import "./CircuitBreaker.sol";

// 掲示板コントラクト
contract BulletinBoard is Mortal, CircuitBreaker {

    // 記事
    struct Article {
        address addr;
        string name;
        string mailaddress;
        string message;
        uint numLiked;
        mapping (uint => address) likedUsers;
    }

    string private defaultName = "名無し"; // デフォルト名前
    string public title; // タイトル
    uint public numArticles;  // 記事数
    uint public maxNumArticles; //最大記事数
    mapping (uint => Article) public articles; // 記事マップ
    mapping (address => uint) public writerBalance; // 投稿者資金
    uint public deadline;   // 締め切り
    uint public winnerAmount;   // 賞金
    bool public isRunningCampagin; // キャンペーン中かどうか

    // コンストラクタ
    function BulletinBoard(string _title, uint _maxNumArticles) public {
        stopped = false;
        numArticles = 0;
        title = _title;
        maxNumArticles = _maxNumArticles;
        isRunningCampagin = false;
    }

    // 記事の投稿
    function postArticle(string _name, string _mailaddress, string _message) public payable isStopped {

        // 送金が0以上の場合
        require(msg.value > 0);

        // 記事数が最大以下の場合
        require(numArticles < maxNumArticles);

        // メッセージが空文字ではない場合
        require(bytes(_message).length != 0);
        
        // 名前が空白の場合は規定値
        string memory name;
        if(bytes(_name).length == 0){
            name = defaultName;
        } else {
            name = _name;
        }

        // 記事の保存
        Article storage article = articles[numArticles++];
        article.addr = msg.sender;
        article.name = name;
        article.mailaddress = _mailaddress;
        article.message = _message;
        article.numLiked = 0;

        winnerAmount += msg.value;
    }

    // 投げ銭
    function postPay(uint articleInt) public payable isStopped {
        // 送金が0でない場合
        require(msg.value >= 0);
        // 記事番号から記事を取得
        Article storage article = articles[articleInt];
        // 記事の投稿者資金へ追加
        writerBalance[article.addr] += msg.value;
    }
    
    // いいね
    function postNice(uint articleInt) public isStopped {
        // 記事番号から記事を取得
        Article storage article = articles[articleInt];

        // 既にいいね済みの場合は処理終了
        for(uint i = 0; i <= article.numLiked; i++){
            require(article.likedUsers[i] != msg.sender);
        }

        article.numLiked++;
        article.likedUsers[article.numLiked] = msg.sender;
    }

    // キャンペーンスタート
    function startCampagin(uint _duration) public onlyOwner {

        // キャンペーン中でない場合
        require(!isRunningCampagin);

        isRunningCampagin = true;
        deadline = now + _duration;
    }

    // キャンペーン終了
    function closeCampagin() public onlyOwner {

        // キャンペーン中の場合
        require(isRunningCampagin);

        // 期間を過ぎた場合
        require(now > deadline);

        isRunningCampagin = false;

        // 一番いいねをもらった記事を選出
        Article storage win = articles[0];
        for(uint i = 1; i < numArticles; i++){
            Article storage article = articles[i];
            if (win.numLiked < article.numLiked) {
                win = article;
            }
        }

        // 賞金の退避
        uint amount = winnerAmount;

        // 賞金の初期化
        winnerAmount = 0;

        // 賞金を付与
        writerBalance[win.addr] += amount;
    }

    // 引き出し処理
    function withdraw() external {
        // 残金が0より大きい場合に処理
        require(writerBalance[msg.sender] > 0);

        // 残金の退避
        uint refundAmount = writerBalance[msg.sender];

        // 残金の更新
        writerBalance[msg.sender] = 0;

        // 送金
        msg.sender.transfer(refundAmount);
    }
}