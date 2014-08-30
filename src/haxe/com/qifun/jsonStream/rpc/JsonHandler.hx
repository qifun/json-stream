/*
 * json-stream
 * Copyright 2014 深圳岂凡网络有限公司 (Shenzhen QiFun Network Corp., LTD)
 * 
 * Author: 杨博 (Yang Bo) <pop.atry@gmail.com>, 张修羽 (Zhang Xiuyu) <zxiuyu@126.com>
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *     http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.qifun.jsonStream.rpc;

import com.qifun.jsonStream.rpc.IJsonService;

@:dox(hide)
@:final
class JsonHandler implements IJsonResponseHandler
{

  var underlying:JsonResponse->Void;

  public function new(underlying:JsonResponse->Void)
  {
    this.underlying = underlying;
  }

  public function onSuccess(stream:JsonStream):Void
  {
    underlying(SUCCESS(stream));
  }

  public function onFailure(stream:JsonStream):Void
  {
    underlying(FAILURE(stream));
  }

}

@:dox(hide)
enum JsonResponse
{
  SUCCESS(stream:JsonStream);
  FAILURE(stream:JsonStream);
}
