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

import com.qifun.jsonStream.JsonStream;
import com.qifun.jsonStream.rpc.IJsonService;

@:final
class IncomingProxy implements IJsonService
{

  var pushFunction:JsonStream->Void;

  var applyFunction:JsonStream->IJsonResponseHandler->Void;

  public function new(pushFunction:JsonStream->Void, applyFunction:JsonStream->IJsonResponseHandler->Void)
  {
    this.pushFunction = pushFunction;
    this.applyFunction = applyFunction;
  }

  public function push(data:JsonStream):Void
  {
    pushFunction(data);
  }

  public function apply(request:JsonStream, responseHandler:IJsonResponseHandler):Void
  {
    applyFunction(request, responseHandler);
  }

}
