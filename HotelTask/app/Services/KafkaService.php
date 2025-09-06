<?php

// namespace App\Services;

// use Kafka\Producer;
// use Kafka\Consumer;

// class KafkaService
// {
//     public static function sendMessage($topic, $message)
//     {
//         $producer = Producer::create([
//             'brokerList' => 'localhost:9092',
//         ]);

//         $producer->send([
//             [
//                 'topic' => $topic,
//                 'value' => json_encode($message),
//                 'key' => '',
//             ],
//         ]);
//     }

//     public static function consumeMessages($topic, $groupId)
//     {
//         $consumer = Consumer::create([
//             'groupId' => $groupId,
//             'brokerList' => 'localhost:9092',
//             'topics' => [$topic],
//         ]);

//         $consumer->consume(function($message) {
//             echo "Received: " . $message['message']['value'] . PHP_EOL;
//         });
//     }
// }

namespace App\Services;

use Kafka\Producer;
use Kafka\ProducerConfig;

class KafkaService
{
    public static function sendMessage(string $topic, array $message)
    {
        $config = ProducerConfig::getInstance();
        $config->setMetadataBrokerList('localhost:9092'); // your Kafka broker
        $config->setRequiredAck(1);
        $config->setIsAsyn(false);
        $config->setProduceInterval(500);

        $producer = new Producer();

        $producer->send([
            [
                'topic' => $topic,
                'value' => json_encode($message),
            ],
        ]);

        return true;
    }
}
